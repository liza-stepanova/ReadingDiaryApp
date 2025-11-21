import UIKit

final class NoteTableViewCell: UITableViewCell {
    
    static let identifier = "NoteTableViewCell"
    
    private let shadowContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
           
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.primaryAccent.cgColor
        view.layer.shadowOpacity = UIConstants.Shadow.opacity
        view.layer.shadowRadius = UIConstants.Shadow.radius
        view.layer.shadowOffset = UIConstants.Shadow.offset
           
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        
        view.layer.borderColor = UIColor.primaryAccent.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIConstants.Font.text2
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private let noteTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIConstants.Font.text1
        label.textColor = .label
        label.numberOfLines = 0
        
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        noteTextLabel.text = nil
    }
    
    func configure(with model: NoteCellViewModel) {
        dateLabel.text = model.dateString
        noteTextLabel.text = model.text
    }
    
    private func setupLayout() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(shadowContainerView)
        shadowContainerView.addSubview(containerView)
        containerView.addSubview(noteTextLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.Layout.Inset.vertical),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UIConstants.Layout.Inset.horizontal),
                   
            shadowContainerView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: UIConstants.Layout.Spacing.small),
            shadowContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.Layout.Inset.horizontal),
            shadowContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UIConstants.Layout.Inset.horizontal),
            shadowContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.Layout.Spacing.small),
                   
            containerView.topAnchor.constraint(equalTo: shadowContainerView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: shadowContainerView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: shadowContainerView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: shadowContainerView.bottomAnchor),
                   
            noteTextLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIConstants.NoteCard.padding),
            noteTextLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.NoteCard.padding),
            noteTextLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.NoteCard.padding),
            noteTextLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIConstants.NoteCard.padding)
        ])
    }
    
}
