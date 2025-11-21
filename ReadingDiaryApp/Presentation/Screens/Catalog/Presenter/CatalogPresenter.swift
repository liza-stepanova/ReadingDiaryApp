import UIKit

final class CatalogPresenter: CatalogPresenterProtocol {
    
    struct Dependencies {
        let interactor: CatalogInteractorInput
    }
    
    private weak var view: CatalogViewProtocol?
    private let interactor: CatalogInteractorInput

    private var books: [Book] = []
    private var viewModels: [BookCellViewModel] = []
    
    private var isLoadingNextPage = false
    
    var numberOfItems: Int { viewModels.count }

    init(dependencies: Dependencies) {
        self.interactor = dependencies.interactor
    }
    
    func setViewController(view: CatalogViewProtocol) {
        self.view = view
    }

    func viewDidLoad() {
        view?.reloadData()
        view?.showEmptyState(false)
    }

    func searchSubmitted(_ text: String) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            cancelAllCoverLoads()
            books = []
            viewModels = []
            view?.setLoading(false)
            view?.showEmptyState(false)
            view?.reloadData()
            return
        }
        view?.showEmptyState(false)
        view?.setLoading(true)
        cancelAllCoverLoads()
        interactor.searchBooks(query: query)
    }

    func cancelSearch() {
        interactor.cancelSearch()
        cancelAllCoverLoads()
        books = []
        viewModels = []
        view?.setLoading(false)
        view?.showEmptyState(false)
        view?.reloadData()
    }
    
    func itemViewModel(at index: Int) -> BookCellViewModel {
        viewModels[index]
    }
    
    func willDisplayItem(at index: Int) {
        guard index >= 0, index < books.count else { return }
        if viewModels[index].cover != nil { return }
        
        guard let url = books[index].coverURL() else {
            viewModels[index].cover = UIConstants.Images.coverPlaceholder
            view?.reloadItems(at: [index])
            return
        }
        interactor.loadCover(for: viewModels[index].id, url: url)
        
        let thresholdIndex = max(0, viewModels.count - 5)
        if index >= thresholdIndex, !isLoadingNextPage {
            isLoadingNextPage = true
            view?.setBottomLoading(true)
            interactor.loadNextPage()
        }

    }
    
    func didEndDisplayingItem(at index: Int) {
        guard index >= 0, index < viewModels.count else { return }
        interactor.cancelCoverLoad(for: viewModels[index].id)
    }
    
    func didToggleFavorite(at index: Int, to isFavorite: Bool) {
        guard index >= 0, index < viewModels.count else { return }
 
        let book = books[index]
        var viewModel = viewModels[index]
        
        viewModel.isFavorite = isFavorite
        viewModels[index] = viewModel
                
        view?.reloadItems(at: [index])
        interactor.updateBookState(
            book: book,
            status: viewModel.status,
            isFavorite: isFavorite,
            cover: viewModel.cover
        )
    }
    
    func didChangeStatus(at index: Int, to status: ReadingStatus) {
        guard index >= 0, index < viewModels.count else { return }
                
        let book = books[index]
        var viewModel = viewModels[index]
                
        viewModel.status = status
        viewModels[index] = viewModel
                
        view?.reloadItems(at: [index])
        interactor.updateBookState(
            book: book,
            status: status,
            isFavorite: viewModel.isFavorite,
            cover: viewModel.cover
        )
    }
    
}

extension CatalogPresenter: CatalogInteractorOutput {
    
    func didLoadBooks(_ books: [Book], isReset: Bool, localState: [String: LocalBook]) {
        if isReset {
            self.books = books
            self.viewModels = books.map { book in
                let local = localState[book.id]
                return BookCellViewModel(
                    id: book.id,
                    title: book.title,
                    author: book.author,
                    cover: nil,
                    status: local?.readingStatus ?? .none,
                    isFavorite: local?.isFavorite ?? false,
                    hasNotes: false
                )
            }
            view?.setLoading(false)
            view?.setBottomLoading(false)
            view?.showEmptyState(viewModels.isEmpty)
            view?.reloadData()
        } else {
            let startIndex = self.books.count
            self.books.append(contentsOf: books)
                        
            let newViewModels: [BookCellViewModel] = books.map { book in
                let local = localState[book.id]
                return BookCellViewModel(
                    id: book.id,
                    title: book.title,
                    author: book.author,
                    cover: nil,
                    status: local?.readingStatus ?? .none,
                    isFavorite: local?.isFavorite ?? false,
                    hasNotes: false
                )
            }
            self.viewModels.append(contentsOf: newViewModels)
            isLoadingNextPage = false
            view?.setBottomLoading(false)
            view?.showEmptyState(viewModels.isEmpty)
            view?.reloadData()
        }
    }

    func didFailSearch(_ error: NetworkError) {
        view?.setLoading(false)
        isLoadingNextPage = false
        view?.setBottomLoading(false)
        view?.showError(message: error.localizedDescription)
    }
    
    func didLoadCover(id: String, image: UIImage) {
        guard let index = indexOfItem(with: id) else { return }
        viewModels[index].cover = image
        view?.updateCover(at: index, image: image)
    }
    
    func didFailLoadCover(id: String, error: NetworkError) {
        if case let .transport(error) = error,
            (error as NSError).code == NSURLErrorCancelled { return }
        
        guard let index = viewModels.firstIndex(where: { $0.id == id }) else { return }
        
        if viewModels[index].cover == nil {
            viewModels[index].cover = UIConstants.Images.coverPlaceholder
            view?.updateCover(at: index, image: UIConstants.Images.coverPlaceholder)
        }
    }
    
    func didFailUpdateBookState(bookId: String, error: any Error) {
        view?.showError(message: error.localizedDescription)
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
