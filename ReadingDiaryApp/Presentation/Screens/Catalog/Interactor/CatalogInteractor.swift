import Foundation
import UIKit

final class CatalogInteractor: CatalogInteractorInput {
    
    struct Dependencies {
        let service: OpenLibraryServiceProtocol
        let imageLoader: ImageLoaderProtocol
        let localBooksRepository: LocalBooksRepositoryProtocol
    }
    
    weak var output: CatalogInteractorOutput?
    
    private let service: OpenLibraryServiceProtocol
    private let imageLoader: ImageLoaderProtocol
    private let localBooksRepository: LocalBooksRepositoryProtocol
    
    private var currentTask: URLSessionDataTask?
    private var coverTasks: [String: URLSessionDataTask] = [:]

    init(dependencies: Dependencies) {
        self.service = dependencies.service
        self.imageLoader = dependencies.imageLoader
        self.localBooksRepository = dependencies.localBooksRepository
    }

    func searchBooks(query: String) {
        currentTask?.cancel()
        currentTask = service.searchBooks(query: query, page: 1, limit: 20) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let books):
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
                                
                    self.output?.didLoadBooks(books, localState: localMap)
                }
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
