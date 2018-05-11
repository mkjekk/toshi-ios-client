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

extension UIAlertController {

    // MARK: - Static helpers

    /// Creates an alert with the given title, message, and actions.
    ///
    /// - Parameters:
    ///   - title: The title to display
    ///   - message: The message to display
    ///   - actions: The actions to display and perform with the alert.
    /// - Returns: The created alert controller, ready to be displayed, or nil if validation failed
    static func alertWith(title: String?,
                          message: String?,
                          actions: [UIAlertAction]) -> UIAlertController? {
        assert(actions.count > 0, "You probably want at least one action")

        guard validateActions(actions) else {
            return nil
        }

        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)

        actions.forEach { alertController.addAction($0) }

        return alertController
    }

    /// Creates and shows an alert with the title "Error" and the given
    /// message, along with an "OK" button to dismiss and perform the optional
    /// action passed in.
    ///
    /// - Parameters:
    ///   - message: The message to display
    ///   - okActionHandler: An action to perform when the alert is dismissed, or nil.
    /// - Returns: The alert, ready to be presented, or nil if validation failed.
    static func okOnlyAlertWith(title: String?,
                                message: String?,
                                okActionHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController? {
        return alertWith(title: title,
                         message: message,
                         actions: [ .okAction(handler: okActionHandler) ])
    }

    private static var errorTitle: String {
        return Localized.error_title
    }

    /// Creates an alert with the title "Error" and the passed-in error's
    /// localized description as the message, along with an "OK" button to dismiss
    /// and perform the optional action passed in.
    ///
    /// - Parameters:
    ///   - error: The error whose `localizedDescription` should be displayed
    ///   - okActionHandler: An action to perform when the alert is dismissed, or nil.
    /// - Returns: The alert, ready to be presented, or nil if validation failed.
    static func errorOKAlertWith(error: Error,
                                 okActionHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController? {
        return okOnlyAlertWith(title: errorTitle,
                               message: (error as NSError).localizedDescription,
                               okActionHandler: okActionHandler)
    }

    /// Creates an alert with the given title and message, along with
    /// an "OK" button to dismiss and perform the optional action passed in.
    ///
    /// - Parameters:
    ///   - title: The title to display
    ///   - message: The message to display
    ///   - okActionHandler: An action to perform when the alert is dismissed, or nil.
    /// - Returns: The alert, ready to be presented, or nil if validation failed.
    static func errorOKAlertWith(message: String?,
                                 okActionHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController? {
        return okOnlyAlertWith(title: errorTitle,
                               message: message,
                               okActionHandler: okActionHandler)
    }

    /// Creates and shows an action sheet-style alert controller.
    ///
    /// - Parameters:
    ///   - title: The title to display or nil. Defaults to nil.
    ///   - message: The message to display or nil. Defaults to nil.
    ///   - actions: The actions to offer on the action sheet.
    /// - Returns: The action sheet, ready to be presented, or nil if validation failed.
    static func actionSheetWith(title: String?,
                                message: String?,
                                actions: [UIAlertAction]) -> UIAlertController? {
        let actionSheet = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: .actionSheet)

        guard validateActions(actions) else {
            return nil
        }

        actions.forEach { actionSheet.addAction($0) }

        return actionSheet
    }

    private static func validateActions(_ actions: [UIAlertAction]) -> Bool {
        let cancelActions = actions.filter { $0.style == .cancel }
        guard cancelActions.count <= 1 else {
            assertionFailure("You can only have one cancel action per alert controller, or you'll get a crash.")
            return false
        }

        return true
    }

    // MARK: - Instance Helpers

    /// Convenience method to show an alert controller in a given view controller
    ///
    /// - Parameter viewController: The view controller the alert controller should be presented from, or nil to do nothing.
    func show(in viewController: UIViewController?) {
        viewController?.present(self, animated: true)
    }

    /// Convenience method to show an alert controller with the navigator
    func showWithNavigator() {
        Navigator.presentModally(self)
    }
}
