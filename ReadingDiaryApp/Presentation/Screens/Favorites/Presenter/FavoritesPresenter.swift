import UIKit

final class FavoritesPresenter: FavoritesPresenterProtocol {
    
    struct Dependencies {
        let interactor: FavoritesInteractorInput
    }

    private weak var view: FavoritesViewProtocol?
    private let interactor: FavoritesInteractorInput

    private var favoriteBooks: [LocalBook] = []
    private var viewModels: [BookCellViewModel] = []

    var numberOfItems: Int { viewModels.count }

    init(dependencies: Dependencies) {
        self.interactor = dependencies.interactor
    }
    
    func setViewController(view: FavoritesViewProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        loadFavorites()
    }
    
    func itemViewModel(at index: Int) -> BookCellViewModel {
        viewModels[index]
    }
    
    func didChangeStatus(for index: Int, to status: ReadingStatus) {
        guard index >= 0, index < favoriteBooks.count else { return }
           
        let bookId = favoriteBooks[index].id
        interactor.updateBookStatus(bookId: bookId, status: status)
        
        favoriteBooks[index].readingStatus = status
        viewModels[index].status = status
           
        view?.reloadItems(at: [index])
    }
    
    func didToggleFavorite(for index: Int, isFavorite: Bool) {
        guard index >= 0, index < favoriteBooks.count else { return }
          
        let bookId = favoriteBooks[index].id
        interactor.toggleFavorite(bookId: bookId, isFavorite: isFavorite)
          
        if !isFavorite {
            favoriteBooks.remove(at: index)
            viewModels.remove(at: index)
            view?.reloadData()
            view?.showEmptyState(favoriteBooks.isEmpty)
        } else {
            viewModels[index].isFavorite = isFavorite
            view?.reloadItems(at: [index])
        }
    }
    
    private func loadFavorites() {
        interactor.fetchFavorites()
    }
    
}

extension FavoritesPresenter: FavoritesInteractorOutput {
    
    func didLoadFavorites(_ books: [LocalBook]) {
        favoriteBooks = books.sorted(by: { $0.dateAdded > $1.dateAdded })
        viewModels = books.map {
            BookCellViewModel(
                id: $0.id,
                title: $0.title,
                author: $0.author,
                cover: $0.coverImageData.flatMap { UIImage(data: $0) },
                status: $0.readingStatus,
                isFavorite: $0.isFavorite
            )
        }
        view?.showEmptyState(viewModels.isEmpty)
        view?.reloadData()
    }

    func didFailFavorites(_ error: Error) {
        view?.showError(message: error.localizedDescription)
    }
    
}

