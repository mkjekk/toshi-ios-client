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

import UIKit

extension UIViewController {

    // MARK: - Alert Style

    /// Creates and shows an alert with the title "Error" and the given
    /// message, along with an "OK" button to dismiss and perform the optional
    /// action passed in.
    ///
    /// - Parameters:
    ///   - message: The message to display
    ///   - okActionHandler: An action to perform when the alert is dismissed, or nil.
    func showErrorOKAlert(message: String?, okActionHandler: ((UIAlertAction) -> Void)? = nil) {
        self.showOKOnlyAlert(title: Localized.error_alert_title, message: message)
    }

    /// Creates and shows an alert with the given title and message, along with
    /// an "OK" button to dismiss and perform the optional action passed in.
    ///
    /// - Parameters:
    ///   - title: The title to display
    ///   - message: The message to display
    ///   - okActionHandler: An action to perform when the alert is dismissed, or nil.
    func showOKOnlyAlert(title: String?, message: String?, okActionHandler: ((UIAlertAction) -> Void)? = nil) {
        self.showAlert(title: title,
                       message: message,
                       actions: [.okAction(handler: okActionHandler)])
    }

    /// Creates and shows an alert with the given title, message, and actions.
    ///
    /// - Parameters:
    ///   - title: The title to display
    ///   - message: The message to display
    ///   - actions: The actions to display and perform with the alert.
    func showAlert(title: String?, message: String?, actions: [UIAlertAction]) {
        assert(actions.count > 0, "You probably want at least one action")

        guard validateActions(actions) else {
            return
        }

        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)

        actions.forEach { alertController.addAction($0) }

        alertController.view.tintColor = Theme.tintColor

        self.present(alertController, animated: true)
    }

    ////// Creates and shows the account safety alert with predefined actions.
    func showSecurityAlert() {
        let backupAction = UIAlertAction(title: Localized.settings_deposit_error_action_backup, style: .default, handler: { _ in
            let passphraseEnableController = PassphraseEnableController()
            let navigationController = UINavigationController(rootViewController: passphraseEnableController)
            Navigator.presentModally(navigationController)
        })

        showAlert(title: Localized.settings_deposit_error_title,
                  message: Localized.settings_deposit_error_message,
                  actions: [
                    .cancelAction(),
                    backupAction
                  ])
    }

    /// Shows a test alert with the given message, a defined title, and an OK button to dismiss it.
    ///
    /// - Parameter message: The message to display on the alert.
    func showTestAlert(message: String) {
        guard UIApplication.isUITesting else {
            assertionFailure("DON'T CALL THIS IN PROD!")
            return
        }

        showOKOnlyAlert(title: TestOnlyString.testAlertTitle,
                        message: message)
    }

    // MARK: - Action Sheet Style

    /// Shows an action sheet-style alert controller.
    ///
    /// - Parameters:
    ///   - title: The title to display or nil. Defaults to nil.
    ///   - message: The message to display or nil. Defaults to nil.
    ///   - actions: The actions to offer on the action sheet.
    func showActionSheet(title: String? = nil,
                         message: String? = nil,
                         actions: [UIAlertAction]) {
        let actionSheet = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: .actionSheet)

        guard validateActions(actions) else {
            return
        }

        actions.forEach { actionSheet.addAction($0) }

        actionSheet.view.tintColor = Theme.tintColor

        present(actionSheet, animated: true)
    }

    // MARK: - Validation

    private func validateActions(_ actions: [UIAlertAction]) -> Bool {
        let cancelActions = actions.filter { $0.style == .cancel }
        guard cancelActions.count <= 1 else {
            assertionFailure("You can only have one cancel action per alert controller, or you'll get a crash.")
            return false
        }

        return true
    }
}
