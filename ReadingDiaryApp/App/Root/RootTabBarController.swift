import UIKit

final class RootTabBarController: UITabBarController {
    
    private let catalogFactory: CatalogModuleFactoryProtocol
    private let favoritesFactory: FavoritesModuleFactoryProtocol
    
    init(catalogFactory: CatalogModuleFactoryProtocol, favoritesFactory: FavoritesModuleFactoryProtocol) {
        self.catalogFactory = catalogFactory
        self.favoritesFactory = favoritesFactory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarAppearance()
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        let viewControllers: [UIViewController] = AppTab.allCases.map { tab in
            let vc = makeScreen(for: tab)
            vc.title = tab.title
            let nav = UINavigationController(rootViewController: vc)
            
            nav.tabBarItem = UITabBarItem(
              title: tab.title,
              image: UIImage(systemName: tab.systemImageName),
              selectedImage: UIImage(systemName: tab.selectedImageName)
            )

            return nav
        }
        
        self.viewControllers = viewControllers
        self.selectedIndex = 0
    }
    
    private func makeScreen(for tab: AppTab) -> UIViewController {
        switch tab {
        case .catalog: return catalogFactory.makeCatalog()
        case .favorite: return favoritesFactory.makeFavorites()
        case .myBooks: return UIViewController()
        case .profile: return UIViewController()
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
        
        let stackLayout = appearance.stackedLayoutAppearance
        stackLayout.normal.iconColor = .primaryAccent
        stackLayout.normal.titleTextAttributes = [.foregroundColor: UIColor.secondaryAccent]
        stackLayout.selected.iconColor = .primaryAccent
        stackLayout.selected.titleTextAttributes = [.foregroundColor: UIColor.primaryAccent]

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
}
