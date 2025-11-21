import Foundation

final class MyBooksInteractor: MyBooksInteractorInput {
    
    struct Dependencies {
        let repository: LocalBooksRepositoryProtocol
    }
    
    weak var output: MyBooksInteractorOutput?
    private let repository: LocalBooksRepositoryProtocol
    
    init(dependencies: Dependencies) {
        self.repository = dependencies.repository
    }
    
    func fetchBooks(filter: MyBooksFilter) {
        repository.fetchMyBooks(filter: filter) { [weak self] result in
            switch result {
            case .success(let books):
                self?.output?.didLoadMyBooks(books)
            case .failure(let error):
                self?.output?.didFailMyBooks(error)
            }
        }
    }
    
    func updateBookStatus(bookId: String, status: ReadingStatus) {
        repository.updateStatus(bookId: bookId, status: status) { [weak self] result in
            if case let .failure(error) = result {
                self?.output?.didFailMyBooks(error)
            }
        }
    }
    
    func toggleFavorite(bookId: String, isFavorite: Bool) {
        repository.toggleFavorite(bookId: bookId, isFavorite: isFavorite) { [weak self] result in
            if case let .failure(error) = result {
                self?.output?.didFailMyBooks(error)
            }
        }
    }
    
}
