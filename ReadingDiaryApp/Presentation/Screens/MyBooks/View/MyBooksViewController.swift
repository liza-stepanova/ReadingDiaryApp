import UIKit

final class MyBooksViewController: UIViewController {
    
    struct Dependencies {
        let presenter: MyBooksPresenterProtocol
    }
    
    private let presenter: MyBooksPresenterProtocol
    
    private let gridView = BookGridView()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "У вас ещё нет книг"
        label.textAlignment = .center
        label.textColor = .secondaryAccent
        label.numberOfLines = 0
        
        return label
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
        setupGridView()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

}

private extension MyBooksViewController {
    
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

extension MyBooksViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCell.identifier, for: indexPath) as? BookCell else {
            return UICollectionViewCell()
        }
        let data = presenter.itemViewModel(at: indexPath.item)
        cell.configure(with: data)
        
        cell.onStatusChange = { [weak self, weak cell] newStatus in
            guard let self, let cell, let currentIndexPath = collectionView.indexPath(for: cell)
            else { return }
            self.presenter.didChangeStatus(for: indexPath.item, to: newStatus)
        }
        
        cell.onFavoriteToggle = {[weak self, weak cell] isFavorite in
            guard let self, let cell, let currentIndexPath = collectionView.indexPath(for: cell)
            else { return }
            self.presenter.didToggleFavorite(for: indexPath.item, isFavorite: isFavorite)
        }
        
        return cell
    }
    
}

extension MyBooksViewController: MyBooksViewProtocol {
    
    func reloadData() {
        gridView.collectionView.reloadData()
    }
    
    func reloadItems(at indexes: [Int]) {
        let collectionView = gridView.collectionView
        DispatchQueue.main.async {
            let paths = indexes
                .filter { $0 >= 0 && $0 < collectionView.numberOfItems(inSection: 0) }
                .map { IndexPath(item: $0, section: 0) }
            guard !paths.isEmpty else { return }
            collectionView.performBatchUpdates({ collectionView.reloadItems(at: paths) }, completion: nil)
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
