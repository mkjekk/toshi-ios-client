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
import TinyConstraints

/// A view controller which can be activated or deactivated from anywhere in the
/// application to blur the current contents of the root view controller.
/// Mostly for security when going to the background.
class ScreenProtectionViewController: UIViewController {

    private static var applicationWindow: UIWindow? {
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let window = appDelegate.window else {
                assertionFailure("Needs access to window")
                return nil
        }

        return window
    }

    /// Creates and shows the view controller from the application window's root view controller.
    static func activate() {
        let protection = ScreenProtectionViewController()
        protection.modalTransitionStyle = .crossDissolve
        applicationWindow?.rootViewController?.present(protection, animated: true, completion: nil)
    }

    /// Dismisses the root view controller's presented view controller if it's of the appropriate type.
    static func deactivate() {
        guard let protection = applicationWindow?.rootViewController?.presentedViewController as? ScreenProtectionViewController else {
            return
        }

        protection.dismiss(animated: true, completion: nil)
    }

    private lazy var visualEffectView: UIView = {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        effectView.translatesAutoresizingMaskIntoConstraints = false
        
        return effectView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        createWindowScreenshot()

        self.view.addSubview(visualEffectView)
        visualEffectView.edgesToSuperview()
    }

    private func createWindowScreenshot() {
        guard let background = ScreenProtectionViewController.applicationWindow?.snapshotView(afterScreenUpdates: false) else {
            return
        }

        self.view.addSubview(background)
        background.edgesToSuperview()
    }
}
