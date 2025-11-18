import Foundation

protocol FavoritesPresenterProtocol {
    
    var numberOfItems: Int { get }
    func itemViewModel(at index: Int) -> BookCellViewModel
    
    func setViewController(view: CatalogViewProtocol)
    func viewDidLoad()
}

protocol FavoritesViewProtocol {
    
    func reloadData()
    func showEmptyState(_ flag: Bool)
    func showError(message: String)
    
}
