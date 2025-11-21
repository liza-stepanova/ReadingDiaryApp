import UIKit

enum MyBooksAssembly {
    
    static func build(repository: LocalBooksRepositoryProtocol, notesRepository: NotesRepositoryProtocol) -> UIViewController {
        let interactor = MyBooksInteractor(dependencies: .init(repository: repository, notesRepository: notesRepository))
        let notesFactory = NotesModuleFactory(notesRepository: notesRepository)
        let router = MyBooksRouter(dependencies: .init(notesFactory: notesFactory))
        let presenter = MyBooksPresenter(dependencies: .init(interactor: interactor, router: router))
        let view = MyBooksViewController(dependencies: .init(presenter: presenter))
        
        interactor.output = presenter
        presenter.setViewController(view)
        router.viewController = view
        
        return view
    }
    
}
