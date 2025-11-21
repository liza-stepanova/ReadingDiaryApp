import UIKit

enum MyBooksAssembly {
    
    static func build(repository: LocalBooksRepositoryProtocol, notesRepository: NotesRepositoryProtocol) -> UIViewController {
        let interactor = MyBooksInteractor(dependencies: .init(repository: repository, notesRepository: notesRepository))
        let presenter = MyBooksPresenter(dependencies: .init(interactor: interactor))
        let view = MyBooksViewController(dependencies: .init(presenter: presenter))
        
        interactor.output = presenter
        presenter.setViewController(view)
        
        return view
    }
    
}
