import Foundation
import UIKit

final class CatalogInteractor: CatalogInteractorInput {
    
    struct Dependencies {
        let service: OpenLibraryServiceProtocol
        let imageLoader: ImageLoaderProtocol
        let localBooksRepository: LocalBooksRepositoryProtocol
    }
    
    private enum Mode {
        case none
        case popular
        case search(query: String)
    }
    
    weak var output: CatalogInteractorOutput?
    
    private let service: OpenLibraryServiceProtocol
    private let imageLoader: ImageLoaderProtocol
    private let localBooksRepository: LocalBooksRepositoryProtocol
    
    private var currentTask: URLSessionDataTask?
    private var coverTasks: [String: URLSessionDataTask] = [:]
    
    private var mode: Mode = .none
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    private var isLoadingPage = false
    private var hasMorePages = true

    init(dependencies: Dependencies) {
        self.service = dependencies.service
        self.imageLoader = dependencies.imageLoader
        self.localBooksRepository = dependencies.localBooksRepository
    }

    func searchBooks(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        currentTask?.cancel()
        currentPage = 0
        hasMorePages = true
                
        guard !trimmed.isEmpty else {
            mode = .none
            return
        }
        mode = .search(query: trimmed)
        loadPage(page: 1, isReset: true)
    }
    
    func loadPopularBooks() {
        currentTask?.cancel()
        currentPage = 0
        hasMorePages = true
        mode = .popular
               
        loadPage(page: 1, isReset: true)
    }
    
    func loadNextPage() {
        guard hasMorePages, !isLoadingPage else { return }
        loadPage(page: currentPage + 1, isReset: false)
    }

    func cancelSearch() {
        currentTask?.cancel()
        currentTask = nil
        isLoadingPage = false
        hasMorePages = true
        currentPage = 0
        mode = .none
    }
    
    func loadCover(for id: String, url: URL) {
        if let cached = imageLoader.cachedImage(for: url) {
            output?.didLoadCover(id: id, image: cached)
            return
        }
        if coverTasks[id] != nil { return }

        let task = imageLoader.load(url) { [weak self] result in
            guard let self else { return }
            self.coverTasks[id] = nil
            switch result {
            case .success(let image):
                self.output?.didLoadCover(id: id, image: image)
            case .failure(let error):
                if error.isCancelled { return }
                self.output?.didFailLoadCover(id: id, error: error)
            }
        }
        
        if let task { coverTasks[id] = task }
    }

    func cancelCoverLoad(for id: String) {
        if let task = coverTasks[id] {
            imageLoader.cancel(task: task)
            coverTasks[id] = nil
        }
    }
    
    func updateBookState(book: Book, status: ReadingStatus, isFavorite: Bool, cover: UIImage?) {
        let coverData = cover?.pngData()
        let local = LocalBook(
            from: book,
            status: status,
            isFavorite: isFavorite,
            coverImageData: coverData
        )
        
        localBooksRepository.upsert(local) { [weak self] result in
            guard let self else { return }
            if case let .failure(error) = result {
                self.output?.didFailUpdateBookState(bookId: book.id, error: error)
            }
        }
    }

    deinit {
        currentTask?.cancel()
        coverTasks.values.forEach { $0.cancel() }
        coverTasks.removeAll()
    }
    
}

private extension CatalogInteractor {
    
    func loadPage(page: Int, isReset: Bool) {
        guard !isLoadingPage else { return }
        isLoadingPage = true
        
        let requestQuery: String
        switch mode {
        case .search(let query):
            requestQuery = query
        case .popular:
            requestQuery = "bestseller"
        case .none:
            isLoadingPage = false
            return
        }
        
        currentTask = service.searchBooks(query: requestQuery, page: page, limit: pageSize) { [weak self] result in
            guard let self else { return }
            self.isLoadingPage = false
                
            switch result {
            case .success(let books):
                self.currentPage = page
                self.hasMorePages = (books.count == self.pageSize)
                    
                let ids = books.map(\.id)
                self.localBooksRepository.fetch(byIDs: ids) { [weak self] localResult in
                    guard let self else { return }
                        
                    let localMap: [String: LocalBook]
                    switch localResult {
                    case .success(let map):
                        localMap = map
                    case .failure:
                        localMap = [:]
                    }
                        
                    self.output?.didLoadBooks(books, isReset: isReset, localState: localMap)
                }
                    
                case .failure(let error):
                    if error.isCancelled { return }
                    self.output?.didFailSearch(error)
            }
        }
    }
    
}
