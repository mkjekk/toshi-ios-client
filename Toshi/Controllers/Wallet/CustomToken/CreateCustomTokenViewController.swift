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
    var customToken = CustomToken()

    let items = [CustomTokenEditItem(.contactAddress), CustomTokenEditItem(.name), CustomTokenEditItem(.symbol), CustomTokenEditItem(.decimals), CustomTokenEditItem(.button)]

    var scrollViewBottomInset: CGFloat = 0.0
    var scrollView: UIScrollView { return tableView }

    lazy var activityIndicator: UIActivityIndicatorView = defaultActivityIndicator()

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: self.view.frame, style: .plain)

        view.backgroundColor = nil
        view.register(CustomTokenCell.self)
        view.dataSource = self
        view.delegate = self
        view.tableFooterView = UIView()
        view.allowsSelection = false
        view.separatorStyle = .none
        view.contentInset.bottom = -16

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        registerForKeyboardNotifications()

        title = "Add Custom Token"
        view.backgroundColor = Theme.viewBackgroundColor

        addSubviewsAndConstraints()

        preferLargeTitleIfPossible(false)
        setupActivityIndicator()
    }

    override func viewDidAppear(_ animated: Bool) {
        makeFirstCellBecomeFirstResponder()
    }

    private func makeFirstCellBecomeFirstResponder() {
        guard let firstCell = tableView.visibleCells.first as? CustomTokenCell else { return }
        firstCell.becomeFirstResponder()
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

        switch item.type {
        case .button:
            cell.setButton()
        default:
            cell.setTitle(item.titleText)
        }

        cell.delegate = self

        return cell
    }
}

extension CreateCustomTokenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard items.count >= indexPath.row else { return }
        let item = items[indexPath.row]
        guard item.type == .button else { return }

        addCustomToken()
    }

    private func addCustomToken() {
        showActivityIndicator()
        guard let address = customToken.contractAddress else { return }
        EthereumAPIClient.shared.addToken(
                with: address,
                name: customToken.name,
                symbol: customToken.symbol,
                decimals: customToken.decimals) { [weak self] success, error in

            guard let strongSelf = self else { return }

            strongSelf.hideActivityIndicator()

            guard success else {
                strongSelf.showErrorOKAlert(message: "Couldn't create token because of: \(error?.description ?? "Unknown error")")
                return
            }

            strongSelf.navigationController?.popViewController(animated: true)
        }
    }
}

extension CreateCustomTokenViewController: CustomTokenCellDelegate {
    func customTokenCellDidUpdate(_ text: String, on cell: CustomTokenCell) {
        guard let indexPath = tableView.indexPath(for: cell), items.count >= indexPath.row else { return }
        let item = items[indexPath.row]

        switch item.type {
        case .contactAddress:
            customToken.contractAddress = text
        case .name:
            customToken.name = text
        case .symbol:
            customToken.symbol = text
        case .decimals:
            guard let decimals = Int(text) else { return }
            customToken.decimals = decimals
        default:
            break
        }
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

extension CreateCustomTokenViewController: ActivityIndicating { /* mix-in */ }

extension CreateCustomTokenViewController: NavBarColorChanging {
    var navTintColor: UIColor? { return Theme.tintColor }
    var navBarTintColor: UIColor? { return Theme.navigationBarColor }
    var navTitleColor: UIColor? { return Theme.darkTextColor }
    var navShadowImage: UIImage? { return UIImage() }
}
