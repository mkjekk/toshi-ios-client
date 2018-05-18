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

final class WalletViewController: UIViewController {

    private let walletHeaderHeight: CGFloat = 180
    private let sectionHeaderHeight: CGFloat = 44
    private let customTokenCellHeight: CGFloat = 81

    lazy var activityIndicator: UIActivityIndicatorView = defaultActivityIndicator()

    private var timer: Timer?

    private var tokenDetailsViewController: TokenEtherDetailViewController?
    private var indexPathForAddCustomTokenCell: IndexPath {
        return IndexPath(row: datasource.numberOfItems, section: 0)
    }

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: self.view.frame, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = nil
        BasicTableViewCell.register(in: view)
        view.delegate = self
        view.dataSource = self
        view.tableFooterView = UIView()
        view.alwaysBounceVertical = true
        view.addSubview(self.refreshControl)

        return view
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refreshControl.tintColor = .white
        
        return refreshControl
    }()

    private lazy var tableHeaderView: SegmentedHeaderView = {
        let walletItemTitles = [Localized.wallet_tokens, Localized.wallet_collectibles]
        let headerView = SegmentedHeaderView(segmentNames: walletItemTitles, delegate: self)
        headerView.backgroundColor = Theme.viewBackgroundColor

        return headerView
    }()

    private lazy var datasource = WalletDatasource(delegate: self)

    private lazy var tokensValueFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 6
        numberFormatter.minimumIntegerDigits = 1

        return numberFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localized.wallet_controller_title
        view.backgroundColor = Theme.lightGrayBackgroundColor

        addSubviewsAndConstraints()

        preferLargeTitleIfPossible(false)

        setupActivityIndicator()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showActivityIndicatorIfOnline()
        datasource.loadItems()

        tokenDetailsViewController = nil

        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.datasource.loadItems()
        }
    }

    private func addSubviewsAndConstraints() {
        view.addSubview(tableView)
        tableView.edges(to: layoutGuide())

        let frame = CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: walletHeaderHeight))

        let headerView = WalletTableHeaderView(frame: frame,
                                               address: Cereal.shared.paymentAddress,
                                               delegate: self)
        tableView.tableHeaderView = headerView
    }

    @objc private func refresh(_ refreshControl: UIRefreshControl) {
        // we need to show the spinner controller on top of the colored view placed on top of the header
        tableView.bringSubview(toFront: refreshControl)

        guard Navigator.reachabilityStatus != .notReachable else {
            refreshControl.endRefreshing()
            return
        }

        datasource.loadItems()
    }

    private func adjustToEmptyState() {

    }

    private func showActivityIndicatorIfOnline() {
        guard Navigator.reachabilityStatus != .notReachable else { return }
        showActivityIndicator()
    }

    func restartTimerIfNeeded() {
        // Do not start timer if there is none currently running
        guard let timer = self.timer else { return }

        timer.invalidate()
        self.timer = nil

        self.timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.datasource.loadItems()
        }
    }

    func invalidateReloadIfNeeded() {
        guard let runningTimer = timer else { return }
        runningTimer.invalidate()
        timer = nil
    }

    func triggerReload(completion: @escaping ((Bool) -> Void)) {
        datasource.loadItems(completion: completion)
    }
}

extension WalletViewController: ClipboardCopying { /* mix-in */ }
extension WalletViewController: SystemSharing { /* mix-in */ }

extension WalletViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.numberOfItems + 1 // we show the add Custom token cell.
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableHeaderView
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return datasource.contentDescription
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath != indexPathForAddCustomTokenCell else {
           return addCustomTokenCell(for: indexPath)
        }
        
        guard let walletItem = datasource.item(at: indexPath.row) else {
            assertionFailure("Can't retrieve item at index: \(indexPath.row)")
            return UITableViewCell()
        }

        var cellData: TableCellData!

        switch datasource.itemsType {
        case .token:
            let tokenValueNumber = NSDecimalNumber(string: walletItem.details, locale: Locale.current)
            let formattedValueString = tokensValueFormatter.string(from: tokenValueNumber)

            if let token = walletItem as? Token, token.isEtherToken == true {
                cellData = TableCellData(title: token.subtitle,
                                         subtitle: token.title,
                                         leftImage: token.localIcon,
                                         topDetails: formattedValueString,
                                         badgeText: token.convertToFiat())
            } else {
                cellData = TableCellData(title: walletItem.subtitle, subtitle: walletItem.title, leftImagePath: walletItem.iconPath, topDetails: formattedValueString)
            }
        case .collectibles:
            cellData = TableCellData(title: walletItem.title, subtitle: walletItem.subtitle, leftImagePath: walletItem.iconPath, details: walletItem.details)
        }

        let configurator = WalletItemCellConfigurator()
        var components = cellData.components
        components.insert(.leftImage)

        let reuseIdentifier = configurator.cellIdentifier(for: components)

        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? BasicTableViewCell else {
            assertionFailure("Can't dequeue basic cell on wallet view controller for given reuse identifier: \(reuseIdentifier)")
            return UITableViewCell()
        }

        configurator.configureCell(cell, with: cellData)
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    private func addCustomTokenCell(for indexPath: IndexPath) -> UITableViewCell {
        let cellData = TableCellData(title: Localized.add_custom_token_title, leftImage: UIImage(named: "add_custom_token")!)

        let configurator = CellConfigurator()
        guard let cell = tableView.dequeueReusableCell(withIdentifier: configurator.cellIdentifier(for: cellData.components), for: indexPath) as? BasicTableViewCell else { return UITableViewCell() }

        configurator.configureCell(cell, with: cellData)
        cell.titleTextField.textColor = Theme.tintColor

        return cell
    }
}

extension WalletViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath != indexPathForAddCustomTokenCell else {
            didSelectCustomTokenCell()
            return
        }

        switch datasource.itemsType {
        case .token:
            guard let token = datasource.item(at: indexPath.row) as? Token else {
                assertionFailure("Can't retrieve item at index: \(indexPath.row)")
                return
            }

            tokenDetailsViewController = TokenEtherDetailViewController(token: token)
            navigationController?.pushViewController(tokenDetailsViewController!, animated: true)
        case .collectibles:
            guard let item = datasource.item(at: indexPath.row) as? Collectible else { return }

            let controller = CollectibleViewController(collectibleContractAddress: item.contractAddress)
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    private func didSelectCustomTokenCell() {
        let controller = CreateCustomTokenViewController()
        Navigator.push(controller)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath != indexPathForAddCustomTokenCell else {
            return customTokenCellHeight
        }

        return UITableViewAutomaticDimension
    }
}

extension WalletViewController: SegmentedHeaderDelegate {

    func segmentedHeader(_: SegmentedHeaderView, didSelectSegmentAt index: Int) {
        guard let itemType = WalletItemType(rawValue: index) else {
            assertionFailure("Can't create wallet item with given selected index: \(index)")
            return
        }

        showActivityIndicatorIfOnline()
        datasource.itemsType = itemType
    }
}

extension WalletViewController: WalletDatasourceDelegate {

    func walletDatasourceDidReload(_ datasource: WalletDatasource, cachedResult: Bool) {
        adjustToEmptyState()
        tableView.reloadData()

        let shouldHideIndicator = !cachedResult || (cachedResult && !datasource.isEmpty)
        guard shouldHideIndicator else { return }
        hideActivityIndicator()
        refreshControl.endRefreshing()

        guard let detailsController = tokenDetailsViewController else { return }
        guard datasource.itemsType == .token,
            let tokens = datasource.items as? [Token],
            let token = tokens.first(where: { $0.contractAddress == detailsController.tokenContractAddress }) else { return }

        detailsController.update(with: token)
    }
}

extension WalletViewController: WalletTableViewHeaderDelegate {

    func copyAddress(_ address: String, from headerView: WalletTableHeaderView) {
        if !Profile.isAccountSecured {
            showSecurityAlert()
        }

        copyToClipboardWithGenericAlert(address)
    }

    func openAddress(_ address: String, from headerView: WalletTableHeaderView) {
        guard let screenshot = tabBarController?.view.snapshotView(afterScreenUpdates: false) else {
            assertionFailure("Could not screenshot?!")
            return
        }
        let qrController = WalletQRCodeViewController(address: address, backgroundView: screenshot)
        qrController.modalTransitionStyle = .crossDissolve
        present(qrController, animated: true)
    }
}

extension WalletViewController: ActivityIndicating { /* mix-in */ }

extension WalletViewController: NavBarColorChanging {
    var navTintColor: UIColor? { return nil }
    var navBarTintColor: UIColor? { return Theme.tintColor }
    var navTitleColor: UIColor? { return Theme.lightTextColor }
    var navShadowImage: UIImage? { return UIImage() }
}
