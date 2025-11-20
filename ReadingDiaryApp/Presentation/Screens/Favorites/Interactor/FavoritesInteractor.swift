import Foundation

final class FavoritesInteractor: FavoritesInteractorInput {
    
    struct Dependencies {
        let repository: LocalBooksRepositoryProtocol
    }
    
    weak var output: FavoritesInteractorOutput?
    private let repository: LocalBooksRepositoryProtocol

    init(dependencies: Dependencies) {
        self.repository = dependencies.repository
    }

    func fetchFavorites() {
        repository.fetchFavorites { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let items):
                self.output?.didLoadFavorites(items)
            case .failure(let err):
                self.output?.didFailFavorites(err)
            }
        }
    }

    func updateBookStatus(bookId: String, status: ReadingStatus) {
        repository.updateStatus(bookId: bookId, status: status) { [weak self] result in
            guard let self else { return }
            if case .failure(let error) = result {
                self.output?.didFailFavorites(error)
            }
        }
    }

    func toggleFavorite(bookId: String, isFavorite: Bool) {
        repository.toggleFavorite(bookId: bookId, isFavorite: isFavorite) { [weak self] result in
            guard let self else { return }
            if case .failure(let err) = result {
                self.output?.didFailFavorites(err)
            }
        }
    }
    
}
