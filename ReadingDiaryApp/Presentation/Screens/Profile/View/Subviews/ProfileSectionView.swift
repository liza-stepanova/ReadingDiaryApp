import UIKit

final class ProfileSectionView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIConstants.Font.h0
        label.textColor = .secondaryAccent
        
        return label
    }()
    
    private let rowsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = UIConstants.Layout.Spacing.small
        
        return stack
    }()

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func addRow(_ row: ProfileRowView) {
        rowsStack.addArrangedSubview(row)
    }

    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(rowsStack)
        
        let inset = UIConstants.Layout.Inset.horizontal
        let spacing = UIConstants.Layout.Spacing.small
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            
            rowsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing),
            rowsStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            rowsStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            rowsStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
