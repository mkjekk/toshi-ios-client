import UIKit

/// Displays user's contacts.
class ContactCell: UITableViewCell {
    var contact: TokenContact? {
        didSet {
            if let contact = self.contact  {
                if contact.name.length > 0 {
                    print(contact.name)
                    self.usernameLabel.text = "@\(contact.username)"
                    self.nameLabel.text = contact.name
                } else {
                    self.nameLabel.text = "@\(contact.username)"
                    self.usernameLabel.text = nil
                }
            } else {
                self.usernameLabel.text = nil
                self.nameLabel.text = nil
            }
        }
    }

    lazy var nameLabel: UILabel = {
        let view = UILabel(withAutoLayout: true)
        view.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        view.textColor = Theme.darkTextColor
        view.font = Theme.semibold(size: 15)

        return view
    }()

    lazy var usernameLabel: UILabel = {
        let view = UILabel(withAutoLayout: true)
        view.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        view.textColor = Theme.greyTextColor
        view.font = Theme.regular(size: 14)

        return view
    }()

    lazy var avatarImageView: UIImageView = {
        let view = UIImageView(withAutoLayout: true)
        view.image = [#imageLiteral(resourceName: "daniel"), #imageLiteral(resourceName: "igor"), #imageLiteral(resourceName: "colin")].any

        return view
    }()

    lazy var separatorView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = Theme.borderColor

        return view
    }()


    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.usernameLabel)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.separatorView)

        let margin: CGFloat = 16.0
        let interLabelMargin: CGFloat = 6.0
        let imageSize: CGFloat = 44.0
        let height: CGFloat = 24.0

        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.layer.cornerRadius = imageSize / 2

        self.avatarImageView.set(height: imageSize)
        self.avatarImageView.set(width: imageSize)
        self.avatarImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        self.avatarImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: margin).isActive = true

        self.nameLabel.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.nameLabel.topAnchor.constraint(greaterThanOrEqualTo: self.contentView.topAnchor, constant: margin).isActive = true
        self.nameLabel.leftAnchor.constraint(equalTo: self.avatarImageView.rightAnchor, constant: margin).isActive = true
        self.nameLabel.rightAnchor.constraint(greaterThanOrEqualTo: self.contentView.rightAnchor, constant: -margin).isActive = true

        self.usernameLabel.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.usernameLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: interLabelMargin).isActive = true
        self.usernameLabel.leftAnchor.constraint(equalTo: self.avatarImageView.rightAnchor, constant: margin).isActive = true
        self.usernameLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -margin).isActive = true
        self.usernameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -margin).isActive = true

        self.separatorView.set(height: 1.0)
        self.separatorView.leftAnchor.constraint(equalTo: self.avatarImageView.rightAnchor).isActive = true
        self.separatorView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.separatorView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}