import UIKit

protocol ProfileModuleFactoryProtocol {
    
    func makeProfile() -> UIViewController
    
}

final class ProfileModuleFactory: ProfileModuleFactoryProtocol {
    
    private let booksRepository: LocalBooksRepositoryProtocol
    private let themeService: ThemeServiceProtocol
    
    init(booksRepository: LocalBooksRepositoryProtocol, themeService: ThemeServiceProtocol) {
        self.booksRepository = booksRepository
        self.themeService = themeService
    }
    
    func makeProfile() -> UIViewController {
        ProfileAssembly.build(booksRepository: booksRepository, themeService: themeService)
    }
    
}
