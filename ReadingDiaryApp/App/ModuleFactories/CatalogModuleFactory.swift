import UIKit

protocol CatalogModuleFactoryProtocol {
    
    func makeCatalog() -> UIViewController
    
}

final class CatalogModuleFactory: CatalogModuleFactoryProtocol {
    
    private let service: OpenLibraryServiceProtocol
    private let imageLoader: ImageLoaderProtocol
    private let localBooksRepository: LocalBooksRepositoryProtocol
    
    init(
        service: OpenLibraryServiceProtocol,
        imageLoader: ImageLoaderProtocol,
        localBooksRepository: LocalBooksRepositoryProtocol
    ) {
        self.service = service
        self.imageLoader = imageLoader
        self.localBooksRepository = localBooksRepository
    }
    
    func makeCatalog() -> UIViewController {
        CatalogAssembly.build(
            service: service,
            imageLoader: imageLoader,
            localBooksRepository: localBooksRepository
        )
    }
    
}

