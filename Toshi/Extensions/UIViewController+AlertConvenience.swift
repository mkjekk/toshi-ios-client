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

        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)

        actions.forEach { alertController.addAction($0) }

        self.present(alertController, animated: true)
    }

    ////// Creates and shows the account safety alert with predefined actions.
    func showSecurityAlert() {
        let alert = UIAlertController(title: Localized.settings_deposit_error_title, message: Localized.settings_deposit_error_message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localized.cancel_action_title, style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: Localized.settings_deposit_error_action_backup, style: .default, handler: { _ in
            let passphraseEnableController = PassphraseEnableController()
            let navigationController = UINavigationController(rootViewController: passphraseEnableController)
            Navigator.presentModally(navigationController)
        }))
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
}
