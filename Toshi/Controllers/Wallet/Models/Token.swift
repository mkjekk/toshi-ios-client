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

/// An individual Token
class Token: Codable {

    private static let EthSymbol = "ETH"
    private static let EthDecimalsCount = 5

    let name: String
    let symbol: String
    let value: String?
    let balance: String
    let decimals: Int
    let contractAddress: String
    let icon: String?
    let weiValueString: String?

    fileprivate(set) var canShowFiatValue = false

    lazy var displayValueString: String = {
        guard self.isEtherToken, let valueInWei = wei else { return self.balance.toDisplayValue(with: self.decimals) }
        return EthereumConverter.ethereumValueString(forWei: valueInWei, withSymbol: false, fractionDigits: 6)
    }()

    var isEtherToken: Bool {
        return symbol == Token.EthSymbol
    }

    enum CodingKeys: String, CodingKey {
        case
        name,
        symbol,
        value,
        balance,
        decimals,
        contractAddress = "contract_address",
        icon,
        weiValueString
    }

    init(name: String,
         symbol: String,
         balance: String,
         decimals: Int,
         contractAddress: String,
         iconPath: String,
         weiValueString: String?) {
        self.name = name
        self.symbol = symbol
        self.balance = balance
        self.value = balance
        self.decimals = decimals
        self.contractAddress = contractAddress
        self.icon = iconPath
        self.weiValueString = weiValueString
    }

    // Create an Eth token from value in wei
    init(valueInWei: NSDecimalNumber) {

        self.name = Localized.wallet_ether_name
        self.symbol = Token.EthSymbol
        self.balance = valueInWei.toHexString
        self.value = self.balance
        self.decimals = Token.EthDecimalsCount
        self.contractAddress = ""
        self.icon = AssetCatalogItem.ether_logo.rawValue
        self.weiValueString = valueInWei.stringValue
        canShowFiatValue = true
    }

    var wei: NSDecimalNumber? {
        guard let weiValueString = weiValueString else { return nil }
        return NSDecimalNumber(string: weiValueString)
    }

    var localIcon: UIImage? {
        guard let iconName = icon else { return nil }
        return UIImage(named: iconName)
    }

    func convertToFiat() -> String? {
        guard let valueInWei = wei else { return nil }
        return EthereumConverter.fiatValueString(forWei: valueInWei, exchangeRate: ExchangeRateClient.exchangeRate)
    }
}

/// Convenience class for decoding an array of Token with the key "tokens"
final class TokenResults: Codable {

    let tokens: [Token]

    enum CodingKeys: String, CodingKey {
        case
        tokens
    }

    init(tokens: [Token]) {
        self.tokens = tokens
    }
}

// MARK: - Wallet Item

extension Token: WalletItem {
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return symbol
    }
    
    var iconPath: String? {
        return icon
    }
    
    var details: String? {
        return displayValueString
    }

    var uniqueIdentifier: String {
        return symbol
    }
}
