import UIKit

final class CatalogViewController: UIViewController {
    
    private let data: [BookCellViewModel] = [
        BookCellViewModel(id: UUID().uuidString, title: "Lfjf", author: "djjdj", cover: UIImage(named: "cover"), status: .none, isFavorite: true),
        BookCellViewModel(id: UUID().uuidString, title: "Преступление и наказание ааооаоао  адзааззазазза захаххахахах", author: "djjdslkfwkjfnjkwnfjwbfhbfwdj", cover: UIImage(named: "cover"), status: .reading, isFavorite: false),
        BookCellViewModel(id: UUID().uuidString, title: "Lfjf", author: "djjdj", cover: UIImage(named: "cover"), status: .none, isFavorite: true),
        BookCellViewModel(id: UUID().uuidString, title: "Lfjf", author: "djjdj", cover: UIImage(named: "cover"), status: .none, isFavorite: true),
        BookCellViewModel(id: UUID().uuidString, title: "Lfjf", author: "djjdj", cover: UIImage(named: "cover"), status: .none, isFavorite: true),
        BookCellViewModel(id: UUID().uuidString, title: "Lfjf", author: "djjdj", cover: UIImage(named: "cover"), status: .none, isFavorite: true),
        BookCellViewModel(id: UUID().uuidString, title: "Lfjf", author: "djjdj", cover: UIImage(named: "cover"), status: .none, isFavorite: true)
    ]
    
    private let gridView = BookGridView()
    
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
        setupGridView()
    }

}

private extension CatalogViewController {
    
    func setupNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    func setupGridView() {
        let collection = gridView.collectionView
        collection.delegate = self
        collection.dataSource = self
        
        view.addSubview(gridView)
        
        NSLayoutConstraint.activate([
            gridView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gridView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
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
