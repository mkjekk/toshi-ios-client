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

enum CustomTokenInputType: Int {
    case text, numbers, button
}

enum CustomTokenEditItemType: Int {
    case none, contactAddress, name, symbol, decimals, button
}

struct CustomTokenEditItem {

    private(set) var type: CustomTokenEditItemType = .none

    private(set) var titleText = ""
    private(set) var detailText = ""
    private(set) var inputType: CustomTokenInputType = .text

    init(_ type: CustomTokenEditItemType) {
        self.type = type

        switch type {
        case .contactAddress:
            titleText = "Contract address"
        case .name:
            titleText = "Name"
        case .symbol:
            titleText = "Symbol"
        case .decimals:
            titleText = "Decimals"
            inputType = .numbers
        case .button:
            titleText = "Button"
            inputType = .button
        default:
            break
        }
    }
}
