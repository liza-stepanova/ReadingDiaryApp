import UIKit

enum MyBooksAssembly {
    
    static func build(repository: LocalBooksRepositoryProtocol) -> UIViewController {
        let interactor = MyBooksInteractor(dependencies: .init(repository: repository))
        let presenter = MyBooksPresenter(dependencies: .init(interactor: interactor))
        let view = MyBooksViewController(dependencies: .init(presenter: presenter))
        
        interactor.output = presenter
        presenter.setViewController(view)
        
        return view
    }
    
}
