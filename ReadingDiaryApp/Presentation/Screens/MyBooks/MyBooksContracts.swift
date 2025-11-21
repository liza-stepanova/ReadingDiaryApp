protocol MyBooksPresenterProtocol: AnyObject {
    
    func itemViewModel(at index: Int) -> BookCellViewModel
    func setViewController(_ view: MyBooksViewProtocol)
    
    var numberOfItems: Int { get }
    func viewDidLoad()
    func viewWillAppear()
    
    func didSelectFilter(at index: Int)
    func didChangeStatus(for index: Int, to status: ReadingStatus)
    func didToggleFavorite(for index: Int, isFavorite: Bool)
    func didTapNotes(for index: Int)
    
}

protocol MyBooksViewProtocol: AnyObject {
    
    func reloadData()
    func reloadItems(at indexes: [Int])
    func showEmptyState(_ flag: Bool)
    func showError(message: String)
    func setSelectedFilterIndex(_ index: Int)
    
}


protocol MyBooksInteractorInput: AnyObject {
    
    func fetchBooks(filter: MyBooksFilter)
    func updateBookStatus(bookId: String, status: ReadingStatus)
    func toggleFavorite(bookId: String, isFavorite: Bool)
    func checkNotesExist(for bookId: String)
    
}

protocol MyBooksInteractorOutput: AnyObject {
    
    func didLoadMyBooks(_ books: [LocalBook])
    func didFailMyBooks(_ error: Error)
    func didUpdateNotesExist(bookId: String, hasNotes: Bool)
    
}
