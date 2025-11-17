protocol CatalogInteractorInput: AnyObject {
    
    func searchBooks(query: String)
    func cancelSearch()
    
}

protocol CatalogInteractorOutput: AnyObject {
    
    func didLoadBooks(_ books: [Book])
    func didFailSearch(_ error: NetworkError)
    
}
