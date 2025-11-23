import UIKit

final class ProfileStatsSectionView: UIView {
    
    private let sectionView = ProfileSectionView(title: "Статистика")
    private let doneReadRow = ProfileRowView()
    private let favoritesRow = ProfileRowView()
    private let readingRow = ProfileRowView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupInitialTitles()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(doneCountText: String, favoritesCountText: String, readingCountText: String) {
        doneReadRow.configure(title: "Прочитано книг", value: doneCountText)
        favoritesRow.configure(title: "Книг в избранном", value: favoritesCountText)
        readingRow.configure(title: "Читаю сейчас", value: readingCountText)
    }
    
}

private extension ProfileStatsSectionView {
    
    func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(sectionView)
        
        NSLayoutConstraint.activate([
            sectionView.topAnchor.constraint(equalTo: topAnchor),
            sectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            sectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        sectionView.addRow(doneReadRow)
        sectionView.addRow(favoritesRow)
        sectionView.addRow(readingRow)
    }
    
    func setupInitialTitles() {
        doneReadRow.configure(title: "Прочитано книг", value: nil)
        favoritesRow.configure(title: "Книг в избранном", value: nil)
        readingRow.configure(title: "Читаю сейчас", value: nil)
    }
    
}
