import Foundation

final class CatalogInteractor: CatalogInteractorInput {
    
    weak var output: CatalogInteractorOutput?
    private let service: OpenLibraryServiceProtocol
    private var currentTask: URLSessionDataTask?

    init(service: OpenLibraryServiceProtocol) {
        self.service = service
    }

    func searchBooks(query: String) {
        currentTask?.cancel()
        currentTask = service.searchBooks(query: query, page: 1, limit: 20) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let books):
                self.output?.didLoadBooks(books)
            case .failure(let error):
                if error.isCancelled { return }
                self.output?.didFailSearch(error)
            }
        }
    }

    func cancelSearch() {
        currentTask?.cancel()
        currentTask = nil
    }
    
}
