import UIKit

enum NotesAssembly {
    
    static func build(bookId: String, bookTitle: String?, repository: NotesRepositoryProtocol) -> UIViewController {
        let interactor = NotesInteractor(
            dependencies: .init(repository: repository, bookId: bookId)
        )
        let router = NotesRouter(dependencies: .init(notesRepository: repository))
        let presenter = NotesPresenter(dependencies: .init(interactor: interactor,
                                                           router: router,
                                                           bookId: bookId,
                                                           bookTitle: bookTitle))
        let view = NotesViewController(dependencies: .init(presenter: presenter,bookTitle: bookTitle))
        interactor.output = presenter
        presenter.setViewController(view)

        return view
    }
    
}
