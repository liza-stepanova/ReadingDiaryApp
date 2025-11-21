import UIKit

enum NoteEditorAssembly {

    static func buildCreate(bookId: String, bookTitle: String?, repository: NotesRepositoryProtocol) -> UIViewController {
        let interactor = NoteEditorInteractor(dependencies: .init(repository: repository, bookId: bookId))
        let presenter = NoteEditorPresenter(dependencies: .init(interactor: interactor,
                                                                mode: .create(bookId: bookId, bookTitle: bookTitle)))
        let view = NoteEditorViewController(dependencies: .init(presenter: presenter, bookTitle: bookTitle))

        interactor.output = presenter
        presenter.setViewController(view)

        return view
    }

    static func buildEdit(note: BookNote, bookTitle: String?, repository: NotesRepositoryProtocol) -> UIViewController {
        let interactor = NoteEditorInteractor(dependencies: .init(repository: repository, bookId: note.bookId))
        let presenter = NoteEditorPresenter(dependencies: .init(interactor: interactor, mode: .edit(note: note)))
        let view = NoteEditorViewController(dependencies: .init(presenter: presenter, bookTitle: bookTitle))

        interactor.output = presenter
        presenter.setViewController(view)

        return view
    }
    
}
