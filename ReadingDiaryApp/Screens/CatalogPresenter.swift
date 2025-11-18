import UIKit

final class CatalogPresenter: CatalogPresenterProtocol {
    
    struct Dependencies {
        let interactor: CatalogInteractorInput
    }
    
    private weak var view: CatalogViewProtocol?
    private let interactor: CatalogInteractorInput

    private var books: [Book] = []
    private var viewModels: [BookCellViewModel] = []
    
    var numberOfItems: Int { viewModels.count }

    init(dependencies: Dependencies) {
        self.interactor = dependencies.interactor
    }
    
    func setViewController(view: CatalogViewProtocol) {
        self.view = view
    }

    func viewDidLoad() {
        view?.reloadData()
        view?.showEmptyState(true)
    }

    func searchSubmitted(_ text: String) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            cancelAllCoverLoads()
            books = []
            viewModels = []
            view?.setLoading(false)
            view?.showEmptyState(true)
            view?.reloadData()
            return
        }
        view?.setLoading(true)
        cancelAllCoverLoads()
        interactor.searchBooks(query: query)
    }

    func cancelSearch() {
        interactor.cancelSearch()
        view?.setLoading(false)
    }
    
    func itemViewModel(at index: Int) -> BookCellViewModel {
        viewModels[index]
    }
    
    func willDisplayItem(at index: Int) {
        guard index >= 0, index < books.count else { return }
        if viewModels[index].cover != nil { return }
        guard let url = books[index].coverURL() else { return }
        interactor.loadCover(for: viewModels[index].id, url: url)
    }
    
    func didEndDisplayingItem(at index: Int) {
        guard index >= 0, index < viewModels.count else { return }
        interactor.cancelCoverLoad(for: viewModels[index].id)
    }
    
}

extension CatalogPresenter: CatalogInteractorOutput {
    
    func didLoadBooks(_ books: [Book]) {
        self.books = books
        self.viewModels = books.map {
            BookCellViewModel(
                id: $0.id,
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
    
    func didLoadCover(id: String, image: UIImage) {
        guard let index = indexOfItem(with: id) else { return }
        viewModels[index].cover = image
        view?.reloadItems(at: [index])
    }
    
    func didFailLoadCover(id: String, error: NetworkError) {
        if case let .transport(error) = error,
            (error as NSError).code == NSURLErrorCancelled { return }
        
        guard let index = viewModels.firstIndex(where: { $0.id == id }) else { return }
        
        if viewModels[index].cover == nil {
            viewModels[index].cover = UIConstants.Images.coverPlaceholder
            view?.reloadItems(at: [index])
        }
    }
    
}

private extension CatalogPresenter {
    
    func cancelAllCoverLoads() {
        for viewModel in viewModels {
            interactor.cancelCoverLoad(for: viewModel.id)
        }
    }

    func indexOfItem(with id: String) -> Int? {
        viewModels.firstIndex { $0.id == id }
    }
    
}
