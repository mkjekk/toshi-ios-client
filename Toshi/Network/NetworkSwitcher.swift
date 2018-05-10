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

extension NSNotification.Name {
    static let SwitchedNetworkChanged = NSNotification.Name(rawValue: "SwitchedNetworkChanged")
}

enum Network: String {

    private static let ActiveNetwork = "ActiveNetwork"

    typealias RawValue = String

    case mainNet = "1"
    case toshiTestNetwork = "116"
    case kovan = "42"
    case rinkeby = "4"
    case ropsten = "3"

    var baseURL: String {
        switch self {
        case .mainNet:
            return "https://ethereum.service.toshi.org"
        case .toshiTestNetwork:
            return "https://ethereum.internal.service.toshi.org"
        case .kovan:
            return "https://toshi-eth-service-kovan.herokuapp.com"
        case .rinkeby:
            return "https://toshi-eth-service-rinkeby.herokuapp.com"
        case .ropsten:
            #if TOSHIDEV
                return "https://ethereum.development.service.toshi.org"
            #else
                return "https://toshi-eth-service-ropsten.herokuapp.com"
            #endif
        }
    }

    var label: String {
        switch self {
        case .mainNet:
            return Localized.mainnet_title
        case .toshiTestNetwork:
            return Localized.toshi_test_network_title
        case .kovan:
            return Localized.kovan_network_title
        case .rinkeby:
            return Localized.rinkeby_network_title
        case .ropsten:
            return Localized.ropsten_network_title
        }
    }
}

final class NetworkSwitcher {
    static let shared = NetworkSwitcher()

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSignOut(_:)), name: .UserDidSignOut, object: nil)
    }

    var activeNetwork: Network {
        guard let switched = self.switchedNetwork else {
            return defaultNetwork
        }

        return switched
    }

    var defaultNetworkBaseUrl: String {
        return defaultNetwork.baseURL
    }

    var isDefaultNetworkActive: Bool {
        return activeNetwork.rawValue == defaultNetwork.rawValue
    }

    var activeNetworkLabel: String {
        return activeNetwork.label
    }

    var activeNetworkBaseUrl: String {
        return activeNetwork.baseURL
    }

    var activeNetworkID: String {
        return activeNetwork.rawValue
    }

    var availableNetworks: [Network] {
        #if DEBUG
            return [.toshiTestNetwork]
        #elseif TOSHIDEV
            return [.ropsten]
        #else
            return [.mainNet, .ropsten, .rinkeby, .kovan]
        #endif
    }

    func activateNetwork(_ network: Network?) {
        guard network?.rawValue != _switchedNetwork?.rawValue else { return }

        deregisterFromActiveNetworkPushNotificationsIfNeeded { success, _ in
            if success {
                self.switchedNetwork = network
            } else {
                DLog("Error deregistering - No connection")
            }
        }
    }

    private var _switchedNetwork: Network?
    private var switchedNetwork: Network? {
        set {
            _switchedNetwork = newValue

            guard let network = _switchedNetwork else {

                UserDefaultsWrapper.activeNetwork = nil

                let notification = Notification(name: .SwitchedNetworkChanged)
                NotificationCenter.default.post(notification)

                return
            }

            registerForSwitchedNetworkPushNotifications { success, error in
                if success {
                    UserDefaultsWrapper.activeNetwork = network.rawValue

                    let notification = Notification(name: .SwitchedNetworkChanged)
                    NotificationCenter.default.post(notification)
                } else {
                    DLog("Error registering: \(String(describing: error))")
                    self.activateNetwork(nil)
                }
            }
        }
        get {
            guard let cachedNetwork = self._switchedNetwork else {
                guard let storedNetworkID = UserDefaultsWrapper.activeNetwork else { return nil }
                _switchedNetwork = Network(rawValue: storedNetworkID)

                return _switchedNetwork
            }

            return cachedNetwork
        }
    }

    private func registerForSwitchedNetworkPushNotifications(completion: @escaping ((_ success: Bool, _ message: String?) -> Void)) {
        EthereumAPIClient.shared.registerForSwitchedNetworkPushNotificationsIfNeeded { success, _ in
            completion(success, nil)
        }
    }

    private func deregisterFromActiveNetworkPushNotificationsIfNeeded(completion: @escaping ((_ success: Bool, _ message: String?) -> Void)) {
        guard let switchedNetwork = self.switchedNetwork, switchedNetwork.rawValue != self.defaultNetwork.rawValue else {
            completion(true, nil)
            return
        }
        guard isDefaultNetworkActive == false && self.switchedNetwork != nil else {
            completion(true, nil)
            return
        }

        EthereumAPIClient.shared.deregisterFromSwitchedNetworkPushNotifications { success, _ in
            completion(success, nil)
        }
    }

    private var defaultNetwork: Network {
        #if DEBUG
            return .toshiTestNetwork
        #elseif TOSHIDEV
            return .ropsten
        #else
            return .mainNet
        #endif
    }

    @objc private func userDidSignOut(_: Notification) {
        activateNetwork(nil)
    }
}
