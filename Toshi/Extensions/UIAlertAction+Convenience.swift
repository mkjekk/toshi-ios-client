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

extension UIAlertAction {

    static func okAction(style: UIAlertActionStyle = .default, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: Localized.alert_ok_action_title,
                             style: style,
                             handler: handler)
    }

    static func cancelAction(style: UIAlertActionStyle = .cancel, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: Localized.cancel_action_title,
                             style: style,
                             handler: handler)
    }

    static func defaultStyleAction(title: String,
                                   handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title,
                             style: .default,
                             handler: handler)
    }

    static func destructiveStyleAction(title: String,
                                       handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title,
                             style: .destructive,
                             handler: handler)
    }

}
