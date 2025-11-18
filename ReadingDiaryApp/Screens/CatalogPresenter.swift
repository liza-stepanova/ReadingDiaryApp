import UIKit

final class CatalogPresenter: CatalogPresenterProtocol {
    
    private weak var view: CatalogViewProtocol?
    private let interactor: CatalogInteractorInput

    private var books: [Book] = []
    private var viewModels: [BookCellViewModel] = []
    
    var numberOfItems: Int { viewModels.count }

    init(view: CatalogViewProtocol,
         interactor: CatalogInteractorInput) {
        self.view = view
        self.interactor = interactor
    }

    func viewDidLoad() {
        view?.reloadData()
        view?.showEmptyState(true)
    }

    func searchSubmitted(_ text: String) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            interactor.cancelSearch()
            books = []
            viewModels = []
            view?.setLoading(false)
            view?.showEmptyState(true)
            view?.reloadData()
            return
        }
        view?.setLoading(true)
        interactor.searchBooks(query: query)
    }

    func cancelSearch() {
        interactor.cancelSearch()
        view?.setLoading(false)
    }
    
    func itemViewModel(at index: Int) -> BookCellViewModel {
        viewModels[index]
    }
    
}

extension CatalogPresenter: CatalogInteractorOutput {
    
    func didLoadBooks(_ books: [Book]) {
        self.books = books
        self.viewModels = books.map {
            BookCellViewModel(
                title: $0.title,
                author: $0.author,
                cover: nil,
                status: .none,
                isFavorite: false
            )
        }
        view?.setLoading(false)
        view?.showEmptyState(viewModels.isEmpty)
        view?.reloadData()
    }

    func didFailSearch(_ error: NetworkError) {
        view?.setLoading(false)
        view?.showError(message: error.localizedDescription)
    }
    
}
