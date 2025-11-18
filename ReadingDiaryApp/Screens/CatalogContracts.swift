protocol CatalogInteractorInput: AnyObject {
    
    func searchBooks(query: String)
    func cancelSearch()
    
}

protocol CatalogInteractorOutput: AnyObject {
    
    func didLoadBooks(_ books: [Book])
    func didFailSearch(_ error: NetworkError)
    
}

protocol CatalogPresenterProtocol: AnyObject {
    
    func viewDidLoad()
    func searchSubmitted(_ text: String)
    func cancelSearch()
    
    var numberOfItems: Int { get }
    func itemViewModel(at index: Int) -> BookCellViewModel
    
}

protocol CatalogViewProtocol: AnyObject {
    
    func setLoading(_ flag: Bool)
    func reloadData()
    func showEmptyState(_ flag: Bool)
    func showError(message: String)
    
}
