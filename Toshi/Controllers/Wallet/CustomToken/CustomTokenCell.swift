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

protocol CustomTokenCellDelegate: class {
    func customTokenCellDidUpdate(_ text: String)
}

final class CustomTokenCell: UITableViewCell {
    static let reuseIdentifier = "CustomTokenCell"
    weak var delegate: CustomTokenCellDelegate?

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = Theme.preferredFootnote()
        titleLabel.textColor = Theme.darkTextHalfAlpha

        return titleLabel
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = Theme.preferredRegularSmall()
        titleLabel.textColor = Theme.mediumTextColor

        return textField
    }()

    private lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = Theme.separatorColor

        return line
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubviewsAndConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()

        return textField.becomeFirstResponder()
    }
    
    private func addSubviewsAndConstraints() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        contentView.addSubview(line)

        titleLabel.top(to: contentView, offset: 16 + 12 + 6.5)
        titleLabel.left(to: contentView, offset: 20)
        titleLabel.right(to: contentView, offset: -20)

        textField.topToBottom(of: titleLabel, offset: 13)
        textField.left(to: contentView, offset: 20)
        textField.right(to: contentView, offset: -20)

        line.topToBottom(of: textField, offset: 8)
        line.left(to: contentView, offset: 20)
        line.right(to: contentView, offset: -20)
        line.bottom(to: contentView)
    }

    func setTitle(_ text: String) {
        titleLabel.text = text
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        textField.text = nil
        titleLabel.text = nil
    }
}

extension CustomTokenCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else { return true }
        delegate?.customTokenCellDidUpdate(text)

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
}
