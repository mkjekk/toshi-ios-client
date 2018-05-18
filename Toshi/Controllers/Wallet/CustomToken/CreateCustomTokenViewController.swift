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
import CameraScanner

final class CreateCustomTokenViewController: UIViewController {
    var customToken = CustomToken() {
        didSet{
            tableView.reloadData()
        }
    }

    let items = [CustomTokenEditItem(.contractAddress), CustomTokenEditItem(.name), CustomTokenEditItem(.symbol), CustomTokenEditItem(.decimals), CustomTokenEditItem(.button)]

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
        case .contractAddress:
            cell.setupScanButton()
            cell.setTitle(item.titleText, value: customToken.contractAddress)
        case .name:
            cell.setTitle(item.titleText, value: customToken.name)
        case .symbol:
            cell.setTitle(item.titleText, value: customToken.symbol)
        case .decimals:
            if let decimals = customToken.decimals {
                cell.setTitle(item.titleText, value: "\(decimals)")
            } else {
                cell.setTitle(item.titleText)
            }
        case .button:
            cell.setupButton()
        default:
            break
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

    private func fetchTokenInfo(for address: String) {
        showActivityIndicator()

        EthereumAPIClient.shared.getToken(with: address) { [weak self] token, error in
            self?.hideActivityIndicator()
            self?.customToken = token ?? CustomToken(contractAddress: address)
         }
    }
}

extension CreateCustomTokenViewController: CustomTokenCellDelegate {
    func customTokenCellDidUpdate(_ text: String, on cell: CustomTokenCell) {
        guard let indexPath = tableView.indexPath(for: cell), items.count >= indexPath.row else { return }
        let item = items[indexPath.row]

        switch item.type {
        case .contractAddress:
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

    func customTokenCellDidRequestScanner(on cell: CustomTokenCell) {
        let controller = ScannerController(instructions: Localized.qr_scanner_instructions, types: [.qrCode])
        controller.delegate = self

        present(controller, animated: true, completion: nil)
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

extension CreateCustomTokenViewController: ScannerViewControllerDelegate {
    func scannerViewControllerDidCancel(_ controller: ScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func scannerViewController(_ controller: ScannerViewController, didScanResult result: String) {

        // We need to process only ethereum address or admin login intent and ignore all the rest
        if let intent = QRCodeIntent(result: result) {
            switch intent {
            case .webSignIn(let loginToken):
                IDAPIClient.shared.adminLogin(loginToken: loginToken) {[weak self] _, _ in
                    SoundPlayer.playSound(type: .scanned)
                    self?.dismiss(animated: true)
                }
            case .addressInput(let address):
                controller.dismiss(animated: true, completion: { [weak self] in
                    self?.fetchTokenInfo(for: address)
                })
            default:
                let alert = UIAlertController(title: Localized.wallet_not_an_address_message, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Localized.alert_ok_action_title, style: .default, handler: { _ in
                    controller.startScanning()
                }))
                alert.addAction(UIAlertAction(title: Localized.cancel_action_title, style: .cancel, handler: { _ in
                    controller.startScanning()
                }))
                Navigator.presentModally(alert)
            }
        }
    }
}