import UIKit

final class MyBooksPresenter: MyBooksPresenterProtocol {
    
    struct Dependencies {
        let interactor: MyBooksInteractorInput
    }
    
    private weak var view: MyBooksViewProtocol?
    private let interactor: MyBooksInteractorInput
    
    private var books: [LocalBook] = []
    private var viewModels: [BookCellViewModel] = []
    
    private var currentFilter: MyBooksFilter = .all
    
    var numberOfItems: Int { viewModels.count }
    
    init(dependencies: Dependencies) {
        self.interactor = dependencies.interactor
    }
    
    func setView(_ view: MyBooksViewProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        view?.setSelectedFilterIndex(index(for: currentFilter))
        interactor.fetchBooks(filter: currentFilter)
    }
    
    func itemViewModel(at index: Int) -> BookCellViewModel {
        viewModels[index]
    }
    
    func didSelectFilter(at index: Int) {
        let newFilter = filter(for: index)
        guard newFilter != currentFilter else { return }
        
        currentFilter = newFilter
        view?.setSelectedFilterIndex(index)
        interactor.fetchBooks(filter: currentFilter)
    }
    
    func didChangeStatus(for index: Int, to status: ReadingStatus) {
        guard index >= 0, index < books.count else { return }
        
        let bookId = books[index].id
        interactor.updateBookStatus(bookId: bookId, status: status)
        
        books[index].readingStatus = status
        viewModels[index].status = status
        
        let shouldRemove: Bool
        switch currentFilter {
        case .all:
            shouldRemove = (status == .none)
        case .reading:
            shouldRemove = (status != .reading)
        case .done:
            shouldRemove = (status != .done)
        }
        
        if shouldRemove {
            books.remove(at: index)
            viewModels.remove(at: index)
            view?.reloadData()
        } else {
            view?.reloadItems(at: [index])
        }
        
        view?.showEmptyState(viewModels.isEmpty)
    }
    
    func didToggleFavorite(for index: Int, isFavorite: Bool) {
        guard index >= 0, index < books.count else { return }
        
        let bookId = books[index].id
        interactor.toggleFavorite(bookId: bookId, isFavorite: isFavorite)
        
        books[index].isFavorite = isFavorite
        viewModels[index].isFavorite = isFavorite
        view?.reloadItems(at: [index])
    }
}

extension MyBooksPresenter: MyBooksInteractorOutput {
    
    func didLoadMyBooks(_ books: [LocalBook]) {
        self.books = books
        self.viewModels = books.map {
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
    
    func didFailMyBooks(_ error: Error) {
        view?.showError(message: error.localizedDescription)
    }
}

private extension MyBooksPresenter {
    
    func filter(for index: Int) -> MyBooksFilter {
        switch index {
        case 1: return .reading
        case 2: return .done
        default: return .all
        }
    }
    
    func index(for filter: MyBooksFilter) -> Int {
        switch filter {
        case .all:     return 0
        case .reading: return 1
        case .done:    return 2
        }
    }
    
}
