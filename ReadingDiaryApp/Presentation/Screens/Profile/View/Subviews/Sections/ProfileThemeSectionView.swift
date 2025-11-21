import UIKit

final class ProfileThemeSectionView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Тема приложения"
        label.font = UIConstants.Font.h0
        label.textColor = .secondaryAccent
        
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Системная", "Светлая", "Тёмная"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.backgroundColor = .clear
        control.selectedSegmentTintColor = .primaryAccent
        
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIConstants.Font.text1,
            .foregroundColor: UIColor.secondaryAccent
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .font: UIConstants.Font.text1,
            .foregroundColor: UIColor.white
        ]
        control.setTitleTextAttributes(normalAttrs, for: .normal)
        control.setTitleTextAttributes(selectedAttrs, for: .selected)
        
        return control
    }()
    
    var onThemeChanged: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelectedIndex(_ index: Int) {
        segmentedControl.selectedSegmentIndex = index
    }
    
    func currentIndex() -> Int {
        segmentedControl.selectedSegmentIndex
    }
}

private extension ProfileThemeSectionView {
    
    func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(segmentedControl)
        
        let inset = UIConstants.Layout.Inset.horizontal
        let spacing = UIConstants.Layout.Spacing.small
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            
            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupActions() {
        segmentedControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    @objc func valueChanged() {
        onThemeChanged?(segmentedControl.selectedSegmentIndex)
    }
    
}
