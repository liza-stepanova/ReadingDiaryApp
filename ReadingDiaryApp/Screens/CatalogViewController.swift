import UIKit

final class CatalogViewController: UIViewController {
    
    struct Dependencies {
        let presenter: CatalogPresenterProtocol
    }
    
    private let presenter: CatalogPresenterProtocol
    
    private let gridView = BookGridView()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.textAlignment = .center
        label.textColor = .secondaryAccent
        label.numberOfLines = 0
        
        return label
    }()

    private let spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = UIConstants.Search.placeholder
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        
        return searchController
    }()
    
    init(dependencies: Dependencies) {
        self.presenter = dependencies.presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupGridView()
        setupSpinner()
        presenter.viewDidLoad()
    }

}

private extension CatalogViewController {
    
    func setupNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchBar.delegate = self
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
    
    func setupSpinner() {
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
}

extension CatalogViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCell.identifier, for: indexPath) as? BookCell else {
            return UICollectionViewCell()
        }
        let data = presenter.itemViewModel(at: indexPath.item)
        cell.configure(with: data)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        presenter.willDisplayItem(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        presenter.didEndDisplayingItem(at: indexPath.item)
    }
    
}

extension CatalogViewController: CatalogViewProtocol {
    
    func setLoading(_ flag: Bool) {
        flag ? spinner.startAnimating() : spinner.stopAnimating()
    }
    
    func reloadData() {
        gridView.collectionView.reloadData()
    }
    
    func reloadItems(at indexes: [Int]) {
        let collectionView = self.gridView.collectionView
        let paths = indexes.map { IndexPath(item: $0, section: 0) }
        DispatchQueue.main.async {
            let safe = paths.filter { $0.item < collectionView.numberOfItems(inSection: 0) }
            guard !safe.isEmpty else { return }
            collectionView.performBatchUpdates(
                { collectionView.reloadItems(at: safe)},
                completion: nil
            )
        }
    }
    
    func updateCover(at index: Int, image: UIImage?) {
        let indexPath = IndexPath(item: index, section: 0)
        if let cell = gridView.collectionView.cellForItem(at: indexPath) as? BookCell {
            cell.setCoverImage(image ?? UIConstants.Images.coverPlaceholder)
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.reloadItems(at: [index])
            }
        }
    }
    
    func showEmptyState(_ flag: Bool) {
        gridView.collectionView.backgroundView = flag ? emptyLabel : nil
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}

extension CatalogViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchSubmitted(searchBar.text ?? "")
        searchBar.resignFirstResponder()
        searchController.isActive = false
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.cancelSearch()
    }
    
}
