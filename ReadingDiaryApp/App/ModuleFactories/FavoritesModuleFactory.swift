import UIKit

protocol FavoritesModuleFactoryProtocol {
    
    func makeFavorites() -> UIViewController
    
}

final class FavoritesModuleFactory: FavoritesModuleFactoryProtocol {
    
    private let repository: LocalBooksRepositoryProtocol
    
    init(repository: LocalBooksRepositoryProtocol) {
        self.repository = repository
    }
    
    func makeFavorites() -> UIViewController {
        FavoritesAssembly.build(repository: repository)
    }
    
}
