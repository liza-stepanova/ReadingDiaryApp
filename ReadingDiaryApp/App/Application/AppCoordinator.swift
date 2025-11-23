import UIKit

protocol Coordinator: AnyObject {
    func start()
}

final class AppCoordinator: Coordinator {
    
    private let window: UIWindow
    private let themeService: ThemeServiceProtocol
    private let appContainer: AppContainer
    
    private lazy var catalogFactory: CatalogModuleFactoryProtocol = {
        CatalogModuleFactory(
            service: appContainer.openLibraryService,
            imageLoader: appContainer.imageLoader,
            localBooksRepository: appContainer.localBooksRepository
        )
    }()
    
    private lazy var favoritesFactory: FavoritesModuleFactoryProtocol = {
        FavoritesModuleFactory(repository: appContainer.localBooksRepository)
    }()
    
    private lazy var myBooksFactory: MyBooksModuleFactoryProtocol = {
        MyBooksModuleFactory(
            repository: appContainer.localBooksRepository,
            notesRepository: appContainer.notesRepository
        )
    }()
    
    private lazy var profileFactory: ProfileModuleFactoryProtocol = {
        ProfileModuleFactory(
            booksRepository: appContainer.localBooksRepository,
            themeService: themeService
        )
    }()
    
    init(window: UIWindow) {
        self.window = window
        
        let themeService = ThemeService(window: window)
        self.themeService = themeService
        self.appContainer = AppContainer(themeService: themeService)
    }
    
    func start() {
        let tabBar = RootTabBarController(
            catalogFactory: catalogFactory,
            favoritesFactory: favoritesFactory,
            myBooksFactory: myBooksFactory,
            profileFactory: profileFactory
        )
        
        window.rootViewController = tabBar
        window.makeKeyAndVisible()
    }
}
