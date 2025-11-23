import UIKit

enum FavoritesAssembly {
    
    static func build(repository: LocalBooksRepositoryProtocol) -> UIViewController {
        let interactor = FavoritesInteractor(dependencies: .init(repository: repository))
        let presenter = FavoritesPresenter(dependencies: .init(interactor: interactor))
        let view = FavoritesViewController(dependencies: .init(presenter: presenter))
        
        interactor.output = presenter
        presenter.setViewController(view: view)
        
        return view
    }
    
}
