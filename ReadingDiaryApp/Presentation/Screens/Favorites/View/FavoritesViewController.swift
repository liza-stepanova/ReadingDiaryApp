import UIKit

final class FavoritesViewController: UIViewController {
    
    struct Dependencies {
        let presenter: FavoritesPresenterProtocol
    }
    
    private let presenter: FavoritesPresenterProtocol
    
    private let gridView = BookGridView()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "У вас ещё нет любимых книг"
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

}

private extension FavoritesViewController {
    
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

extension FavoritesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
    
}

extension FavoritesViewController: FavoritesViewProtocol {
    
    func reloadData() {
        gridView.collectionView.reloadData()
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
