import Foundation

protocol FavoritesPresenterProtocol: AnyObject {
    
    var numberOfItems: Int { get }
    func itemViewModel(at index: Int) -> BookCellViewModel
    
    func setViewController(view: FavoritesViewProtocol)
    func viewDidLoad()
    
    func didChangeStatus(for index: Int, to status: ReadingStatus)
    func didToggleFavorite(for index: Int, isFavorite: Bool)
}

protocol FavoritesViewProtocol: AnyObject {
    
    func reloadData()
    func reloadItems(at indexes: [Int])
    func showEmptyState(_ flag: Bool)
    func showError(message: String)
    
}

protocol FavoritesInteractorInput: AnyObject {
    
    func fetchFavorites()
    func updateBookStatus(bookId: String, status: ReadingStatus)
    func toggleFavorite(bookId: String, isFavorite: Bool)
    
}

protocol FavoritesInteractorOutput: AnyObject {
    
    func didLoadFavorites(_ books: [LocalBook])
    func didFailFavorites(_ error: Error)
    
}

protocol FavoritesRepositoryProtocol {
    
    func fetchFavorites(completion: @escaping (Result<[LocalBook], Error>) -> Void)
    func upsert(_ book: LocalBook, completion: @escaping (Result<Void, Error>) -> Void)
    func updateStatus(bookId: String, status: ReadingStatus, completion: @escaping (Result<Void, Error>) -> Void)
    func toggleFavorite(bookId: String, isFavorite: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(bookId: String, completion: @escaping (Result<Void, Error>) -> Void)
    
}

