import UIKit

final class BookCell: UICollectionViewCell {
    
    static let identifier: String = "BookCell"
    
    var onStatusChange: ((ReadingStatus) -> Void)?
    var onFavoriteToggle: ((Bool) -> Void)?
    
    private var currentStatus: ReadingStatus = .none
    private var currentIsFavorite: Bool = false
    
    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let coverSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    private let bookTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIConstants.Font.h3
        label.textColor = .defaultText
        label.numberOfLines = 0
        
        return label
    }()
    
    private let bookAuthorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIConstants.Font.text2
        label.textColor = .secondaryAccent
        label.numberOfLines = 0
        
        return label
    }()
    
    private let statusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true
        button.tintColor = .primaryAccent
        
        return button
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .primaryAccent
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bookImageView.image = nil
        bookTitleLabel.text = nil
        bookAuthorLabel.text = nil
    }
    
    func configure(with model: BookCellViewModel) {
        bookTitleLabel.text = model.title
        bookAuthorLabel.text = model.author
        currentStatus = model.status
        currentIsFavorite = model.isFavorite
        
        if let image = model.cover {
            bookImageView.image = image
            coverSpinner.stopAnimating()
        } else {
//            bookImageView.image = UIConstants.Images.coverPlaceholder
            coverSpinner.startAnimating()
        }
        
        applyStatusAppearance()
        rebuildStatusMenu()
        applyFavoriteAppearance()
    }
    
    func setCoverImage(_ image: UIImage?) {
        bookImageView.image = image
        coverSpinner.stopAnimating()
    }
    
}

private extension BookCell {
    
    func setupLayout() {
        contentView.addSubview(bookImageView)
        contentView.addSubview(coverSpinner)
        contentView.addSubview(bookTitleLabel)
        contentView.addSubview(bookAuthorLabel)
        contentView.addSubview(statusButton)
        contentView.addSubview(favoriteButton)
        
        NSLayoutConstraint.activate([
            bookImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bookImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bookImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bookImageView.heightAnchor.constraint(equalTo: bookImageView.widthAnchor, multiplier: UIConstants.BookCard.Size.imageHeightMultiplier),
            
            coverSpinner.centerXAnchor.constraint(equalTo: bookImageView.centerXAnchor),
            coverSpinner.centerYAnchor.constraint(equalTo: bookImageView.centerYAnchor),
            
            bookTitleLabel.topAnchor.constraint(equalTo: bookImageView.bottomAnchor, constant: UIConstants.BookCard.Spacing.vertical),
            bookTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bookTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            bookAuthorLabel.topAnchor.constraint(equalTo: bookTitleLabel.bottomAnchor, constant: UIConstants.BookCard.Spacing.vertical),
            bookAuthorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bookAuthorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            statusButton.topAnchor.constraint(equalTo: bookAuthorLabel.bottomAnchor, constant: UIConstants.BookCard.Spacing.vertical),
            statusButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statusButton.heightAnchor.constraint(equalToConstant: UIConstants.BookCard.Size.iconHeight),
            statusButton.widthAnchor.constraint(equalToConstant: UIConstants.BookCard.Size.iconWidth),
            statusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            favoriteButton.topAnchor.constraint(equalTo: bookAuthorLabel.bottomAnchor, constant: UIConstants.BookCard.Spacing.vertical),
            favoriteButton.leadingAnchor.constraint(equalTo: statusButton.trailingAnchor, constant: UIConstants.BookCard.Spacing.horizontal),
            favoriteButton.heightAnchor.constraint(equalToConstant: UIConstants.BookCard.Size.iconHeight),
            favoriteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    func setupActions() {
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    func rebuildStatusMenu() {
        let actions: [UIAction] = ReadingStatus.allCases.map { status in
            let state: UIMenuElement.State = (status == currentStatus) ? .on : .off
            return UIAction(
                title: status.menuTitle,
                image: UIImage(systemName: status.iconName),
                state: state
            ) { [weak self] _ in
                self?.setStatus(status)
            }
        }
        let menu = UIMenu(title: "Статус чтения", options: [.singleSelection], children: actions)
        statusButton.menu = menu
    }

    func setStatus(_ status: ReadingStatus) {
        currentStatus = status
        applyStatusAppearance()
        rebuildStatusMenu()
        onStatusChange?(status)
    }
    
    func applyStatusAppearance() {
        statusButton.setImage(UIImage(systemName: currentStatus.iconName), for: .normal)
    }
    
    @objc func favoriteButtonTapped() {
        currentIsFavorite.toggle()
        applyFavoriteAppearance()
        onFavoriteToggle?(currentIsFavorite)
    }

    func applyFavoriteAppearance() {
        let name = currentIsFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: name), for: .normal)
        favoriteButton.isSelected = currentIsFavorite
    }
    
}
