import UIKit

final class ProfileRowView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        
        view.layer.cornerRadius = UIConstants.Profile.rowCornerRadius
        view.layer.borderWidth =  UIConstants.Profile.rowBorderWidth
        view.layer.borderColor = UIColor.primaryAccent.cgColor
        
        view.layer.shadowColor = UIColor.primaryAccent.cgColor
        view.layer.shadowOpacity = UIConstants.Shadow.opacity
        view.layer.shadowRadius = UIConstants.Shadow.radius
        view.layer.shadowOffset = UIConstants.Shadow.offset
        view.layer.masksToBounds = false
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIConstants.Font.text1
        label.textColor = .defaultText
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIConstants.Font.h1
        label.textColor = .primaryAccent
        label.textAlignment = .right
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, value: String?) {
        titleLabel.text = title
        valueLabel.text = value
    }
}

private extension ProfileRowView {
    
    func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        
        let inset = UIConstants.Layout.Inset.horizontal
        let vertical = UIConstants.Layout.Spacing.small
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: inset),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -inset),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            valueLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: vertical),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -vertical),
            valueLabel.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: vertical),
            valueLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -vertical)
        ])
    }
    
}
