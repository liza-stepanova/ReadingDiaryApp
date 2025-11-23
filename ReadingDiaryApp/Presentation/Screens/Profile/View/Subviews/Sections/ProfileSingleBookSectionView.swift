import UIKit

final class ProfileSingleBookSectionView: UIView {
    
    private let sectionView: ProfileSectionView
    private let rowView = ProfileRowView()
    
    init(title: String) {
        self.sectionView = ProfileSectionView(title: title)
        super.init(frame: .zero)
        setupLayout()
        rowView.configure(title: "—", value: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(bookTitle: String?) {
        let titleText = (bookTitle?.isEmpty == false) ? bookTitle! : "—"
        rowView.configure(title: titleText, value: nil)
    }
    
}

private extension ProfileSingleBookSectionView {
    
    func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(sectionView)
        
        NSLayoutConstraint.activate([
            sectionView.topAnchor.constraint(equalTo: topAnchor),
            sectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            sectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        sectionView.addRow(rowView)
    }
    
}
