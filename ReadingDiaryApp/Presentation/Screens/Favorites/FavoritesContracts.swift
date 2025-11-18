import Foundation

protocol FavoritesPresenterProtocol {
    
    var numberOfItems: Int { get }
    func itemViewModel(at index: Int) -> BookCellViewModel
    
    func setViewController(view: FavoritesViewProtocol)
    func viewDidLoad()
    
    func didChangeStatus(for index: Int, to status: ReadingStatus)
    func didToggleFavorite(for index: Int, isFavorite: Bool)
}

protocol FavoritesViewProtocol {
    
    func reloadData()
    func showEmptyState(_ flag: Bool)
    func showError(message: String)
    
}

protocol FavoritesInteractorInput {
    
}
