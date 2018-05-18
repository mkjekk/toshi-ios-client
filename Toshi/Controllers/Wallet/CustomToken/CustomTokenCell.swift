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
    func customTokenCellDidUpdate(_ text: String, on cell: CustomTokenCell)
    func customTokenCellDidRequestScanner(on cell: CustomTokenCell)
}

final class CustomTokenCell: UITableViewCell {
    static let reuseIdentifier = "CustomTokenCell"

    weak var delegate: CustomTokenCellDelegate?

    var scanButtonHiddenConstraint: NSLayoutConstraint?
    var scanButtonShownConstraint: NSLayoutConstraint?

    private lazy var scanButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageAsset.scan, for: .normal)
        button.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)

        return button
    }()


    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = Theme.preferredFootnote()
        titleLabel.textColor = Theme.darkTextHalfAlpha

        return titleLabel
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.adjustsFontForContentSizeCategory = true
        textField.font = Theme.preferredRegularSmall()
        textField.textColor = Theme.mediumTextColor
        textField.delegate = self

        return textField
    }()

    private lazy var addTokenButton: ActionButton = {
        let view = ActionButton(margin: 16)
        view.title = "ADD TOKEN"
        view.isHidden = true

        return view
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
        contentView.addSubview(addTokenButton)
        contentView.addSubview(scanButton)

        titleLabel.top(to: contentView, offset: 16 + 12 + 6.5)
        titleLabel.left(to: contentView, offset: 20)
        titleLabel.right(to: contentView, offset: -20)

        textField.topToBottom(of: titleLabel, offset: 13)
        textField.left(to: contentView, offset: 20)

        scanButton.leftToRight(of: textField, offset: 10)
        scanButton.centerY(to: textField)
        scanButton.height(28)
        scanButton.right(to: contentView, offset: -10)
        scanButtonHiddenConstraint = scanButton.width(0)
        scanButtonShownConstraint = scanButton.width(28, isActive: false)

        line.topToBottom(of: textField, offset: 8)
        line.left(to: contentView, offset: 20)
        line.right(to: contentView, offset: -20)
        line.bottom(to: contentView)
        line.height(.lineHeight)

        addTokenButton.bottom(to: contentView)
        addTokenButton.left(to: contentView, offset: 16)
        addTokenButton.right(to: contentView, offset: -16)
    }

    func setTitle(_ text: String) {
        titleLabel.text = text
    }

    func setupButton() {
        addTokenButton.isHidden = false
    }

    func setupScanButton() {
        scanButtonHiddenConstraint?.isActive = false
        scanButtonShownConstraint?.isActive = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        textField.text = nil
        titleLabel.text = nil

        addTokenButton.isHidden = true

        scanButtonShownConstraint?.isActive = false
        scanButtonHiddenConstraint?.isActive = true
    }

    @objc func scanButtonTapped() {
        delegate?.customTokenCellDidRequestScanner(on: self)
    }
}

extension CustomTokenCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else { return true }
        delegate?.customTokenCellDidUpdate(text, on: self)

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
}
