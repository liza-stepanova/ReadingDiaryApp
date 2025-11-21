import UIKit

enum ProfileAssembly {
    
    static func build(booksRepository: LocalBooksRepositoryProtocol, themeService: ThemeServiceProtocol) -> UIViewController {
        let interactor = ProfileInteractor(dependencies: .init(booksRepository: booksRepository,
                                                               themeService: themeService))
        let presenter = ProfilePresenter(dependencies: .init(interactor: interactor,
                                                             displayName: "Читатель"))
        let view = ProfileViewController(dependencies: .init(presenter: presenter))
        
        interactor.output = presenter
        presenter.setViewController(view)
        
        return view
    }
    
}
