import Foundation

final class CatalogInteractor: CatalogInteractorInput {
    
    struct Dependencies {
        let service: OpenLibraryServiceProtocol
        let imageLoader: ImageLoaderProtocol
    }
    
    weak var output: CatalogInteractorOutput?
    
    private let service: OpenLibraryServiceProtocol
    private let imageLoader: ImageLoaderProtocol
    
    private var currentTask: URLSessionDataTask?
    private var coverTasks: [String: URLSessionDataTask] = [:]

    init(dependencies: Dependencies) {
        self.service = dependencies.service
        self.imageLoader = dependencies.imageLoader
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

    deinit {
        currentTask?.cancel()
        coverTasks.values.forEach { $0.cancel() }
        coverTasks.removeAll()
    }
    
}
