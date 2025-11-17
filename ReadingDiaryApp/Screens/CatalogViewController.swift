import UIKit

final class CatalogViewController: UIViewController {
    
    private let data: [BookCellViewModel] = [
        BookCellViewModel(title: "Lfjf", author: "djjdj", cover: UIImage(named: "cover"), status: .none, isFavorite: true),
        BookCellViewModel(title: "Преступление и наказание ааооаоао  адзааззазазза захаххахахах", author: "djjdslkfwkjfnjkwnfjwbfhbfwdj", cover: UIImage(named: "cover"), status: .reading, isFavorite: false),
        BookCellViewModel(title: "Lfjf", author: "djjdj", cover: UIImage(named: "cover"), status: .none, isFavorite: true),
        BookCellViewModel(title: "Lfjf", author: "djjdj", cover: UIImage(named: "cover"), status: .none, isFavorite: true),
        BookCellViewModel(title: "Lfjf", author: "djjdj", cover: UIImage(named: "cover"), status: .none, isFavorite: true),
        BookCellViewModel(title: "Lfjf", author: "djjdj", cover: UIImage(named: "cover"), status: .none, isFavorite: true),
        BookCellViewModel(title: "Lfjf", author: "djjdj", cover: UIImage(named: "cover"), status: .none, isFavorite: true)
    ]
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = UIConstants.Search.placeholder
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupCollectionView()
    }

}

private extension CatalogViewController {
    
    func setupNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: BookCell.identifier)
        collectionView.setCollectionViewLayout(makeGridLayout(), animated: false)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func makeGridLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let columns = UIConstants.BookGrid.columns
            let itemH = UIConstants.BookGrid.Spacing.itemHorizontal
            let itemV = UIConstants.BookGrid.Spacing.itemVertical
            let fraction = 1.0 / CGFloat(columns)

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(fraction),
                heightDimension: .estimated(UIConstants.BookGrid.Size.estimatedHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: itemV, leading: itemH, bottom: itemV, trailing: itemH)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(UIConstants.BookGrid.Size.estimatedHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = UIConstants.BookGrid.Spacing.sectionInsets
            section.interGroupSpacing = UIConstants.BookGrid.Spacing.row
            
            return section
        }
    }
    
}

extension CatalogViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCell.identifier, for: indexPath) as? BookCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: data[indexPath.row])
        return cell
    }
    
}
