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

final class CreateCustomTokenViewController: UIViewController {

    let items = [CustomTokenEditItem(.contactAddress), CustomTokenEditItem(.name), CustomTokenEditItem(.symbol), CustomTokenEditItem(.decimals), CustomTokenEditItem(.button)]

    var scrollViewBottomInset: CGFloat = 0.0
    var scrollView: UIScrollView { return tableView }

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: self.view.frame, style: .plain)

        view.backgroundColor = nil
        view.register(CustomTokenCell.self)
        view.dataSource = self
        view.tableFooterView = UIView()

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()


        registerForKeyboardNotifications()

        title = "Add Custom Token"
        view.backgroundColor = Theme.lightGrayBackgroundColor

        addSubviewsAndConstraints()

        preferLargeTitleIfPossible(false)
    }

    private func addSubviewsAndConstraints() {
        view.addSubview(tableView)
        tableView.edgesToSuperview()
    }
}

extension CreateCustomTokenViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTokenCell.reuseIdentifier, for: indexPath) as? CustomTokenCell else {
            assertionFailure("Can't dequeue basic cell on wallet view controller for given reuse identifier: \(CustomTokenCell.reuseIdentifier)")
            return UITableViewCell()
        }

        guard items.count >= indexPath.row else { return UITableViewCell() }
        let item = items[indexPath.row]

        cell.setTitle(item.titleText)
        return cell
    }
}

// MARK: - Keyboard Adjustable

extension CreateCustomTokenViewController: KeyboardAdjustable {

    var keyboardWillShowSelector: Selector {
        return #selector(keyboardShownNotificationReceived(_:))
    }

    var keyboardWillHideSelector: Selector {
        return #selector(keyboardHiddenNotificationReceived(_:))
    }

    @objc private func keyboardShownNotificationReceived(_ notification: NSNotification) {
        keyboardWillShow(notification)
    }

    @objc private func keyboardHiddenNotificationReceived(_ notification: NSNotification) {
        keyboardWillHide(notification)
    }
}
