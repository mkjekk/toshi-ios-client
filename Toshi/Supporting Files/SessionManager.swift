// Copyright (c) 2018 Token Browser, Inc
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation

enum SignInResult {
    case succeeded
    case passphraseVerificationFailure
    case signUpWithPassphrase
    case notConnected
}

final class SessionManager {

    static let shared = SessionManager()

    private(set) var networkManager: TSNetworkManager
    private(set) var profilesManager: ProfilesManager
    private(set) var contactsUpdater: ContactsUpdater
    private(set) var messageSender: MessageSender
    private(set) var messageFetcherJob: MessageFetcherJob?

    init() {
        self.networkManager = TSNetworkManager.shared()
        self.profilesManager = ProfilesManager()
        self.contactsUpdater = ContactsUpdater.shared()

        messageSender = MessageSender(networkManager: networkManager, storageManager: TSStorageManager.shared(), contactsManager: profilesManager, contactsUpdater: contactsUpdater)
    }

    func setupSecureEnvironment() {
        TSAccountManager.sharedInstance().storeLocalNumber(Cereal.shared.address)

        let sharedEnv = TextSecureKitEnv(callMessageHandler: EmptyCallHandler(), contactsManager: profilesManager, messageSender: messageSender, notificationsManager: SignalNotificationManager(), profileManager: ProfileManager.shared())
        TextSecureKitEnv.setShared(sharedEnv)

        messageFetcherJob = MessageFetcherJob(messageReceiver: OWSMessageReceiver.sharedInstance(), networkManager: networkManager, signalService: OWSSignalService.sharedInstance())
    }

    func signOutUser() {

        TSAccountManager.unregisterTextSecure(success: {

            NotificationCenter.default.post(name: .UserDidSignOut, object: nil)
            AvatarManager.shared.cleanCache()

            UserDefaultsWrapper.clearAllDefaultsForThisApplication()

            EthereumAPIClient.shared.deregisterFromMainNetworkPushNotifications()

            let shouldBackupChatDB = Profile.current?.verified ?? false
            TSStorageManager.shared().resetSignalStorage(withBackup: shouldBackupChatDB)
            Yap.sharedInstance.wipeStorage()

            UserDefaultsWrapper.requiresSignIn = true

            UIApplication.shared.applicationIconBadgeNumber = 0

            SessionManager.shared.profilesManager.clearProfiles()

            exit(0)

        }, failure: { _ in
            UIAlertController.okOnlyAlertWith(title: Localized.sign_out_failure_title,
                                              message: Localized.sign_out_failure_message)?.showWithNavigator()
        })
    }

    func signInUser(_ passphrase: [String], completion: @escaping ((SignInResult) -> Void)) {
        guard Cereal.areWordsValid(passphrase), let validCereal = Cereal(words: passphrase) else {
            completion(.passphraseVerificationFailure)
            return
        }
        
        let idClient = IDAPIClient.shared
        idClient.retrieveUser(username: validCereal.address) { profile, _ in

            guard let status = Navigator.tabbarController?.reachabilityManager.currentReachabilityStatus else {
                // Can't check status but just to be safe:
                return
            }

            if status == .notReachable {
                completion(.notConnected)
                return
            }

            guard let profile = profile else {
                completion(.signUpWithPassphrase)
                return
            }

            Cereal.setSharedCereal(validCereal)
            UserDefaultsWrapper.requiresSignIn = false

            Profile.setupCurrentProfile(profile)

            idClient.migrateCurrentUserIfNeeded()

            Profile.current?.updateVerificationState(true)

            ChatAPIClient.shared.registerUser()

            (UIApplication.shared.delegate as? AppDelegate)?.didSignInUser()

            completion(.succeeded)
        }
    }

    func createNewUser(completion: @escaping (Bool) -> Void) {
        IDAPIClient.shared.registerUserIfNeeded { [weak self] status in
            guard status != UserRegisterStatus.failed else {
                completion(false)
                return
            }

            UserDefaultsWrapper.requiresSignIn = false

            (UIApplication.shared.delegate as? AppDelegate)?.setupDB()

            self?.profilesManager.clearProfiles()

            ChatAPIClient.shared.registerUser(completion: { _ in
                guard status == UserRegisterStatus.registered else {
                    completion(false)
                    return
                }
                ChatInteractor.triggerBotGreeting()
                completion(true)
            })
        }
    }
}
