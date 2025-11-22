import UIKit

protocol CatalogInteractorInput: AnyObject {
    
    func searchBooks(query: String)
    func loadPopularBooks() 
    func loadNextPage()
    func cancelSearch()
    
    func loadCover(for id: String, url: URL)
    func cancelCoverLoad(for id: String)
    
    func updateBookState(book: Book, status: ReadingStatus, isFavorite: Bool, cover: UIImage?)
}

protocol CatalogInteractorOutput: AnyObject {
    
    func didLoadBooks(_ books: [Book], isReset: Bool, localState: [String: LocalBook])
    func didFailSearch(_ error: NetworkError)
    
    func didLoadCover(id: String, image: UIImage)
    func didFailLoadCover(id: String, error: NetworkError)
    
    func didFailUpdateBookState(bookId: String, error: Error) 
    
}

protocol CatalogPresenterProtocol: AnyObject {
    
    func setViewController(view: CatalogViewProtocol)
    func viewDidLoad()
    func searchSubmitted(_ text: String)
    func cancelSearch()
    
    var numberOfItems: Int { get }
    func itemViewModel(at index: Int) -> BookCellViewModel
    
    func willDisplayItem(at index: Int)
    func didEndDisplayingItem(at index: Int)
    
    func didToggleFavorite(at index: Int, to isFavorite: Bool)
    func didChangeStatus(at index: Int, to status: ReadingStatus)
    
}

protocol CatalogViewProtocol: AnyObject {
    
    func setLoading(_ flag: Bool)
    func setBottomLoading(_ flag: Bool)
    
    func reloadData()
    func reloadItems(at indexes: [Int])
    func updateCover(at index: Int, image: UIImage?)
    
    func showEmptyState(_ flag: Bool)
    func showError(message: String)
    
}
