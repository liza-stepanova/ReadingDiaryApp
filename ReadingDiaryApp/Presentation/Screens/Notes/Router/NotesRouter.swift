import UIKit

final class NotesRouter: NotesRouterInput {
    
    struct Dependencies {
        let notesRepository: NotesRepositoryProtocol
    }
    
    weak var viewController: UIViewController?
    private let notesRepository: NotesRepositoryProtocol
    
    init(dependencies: Dependencies) {
        self.notesRepository = dependencies.notesRepository
    }
    
    func showAddNote(for bookId: String, title: String?) {
        let vc = NoteEditorAssembly.buildCreate(
            bookId: bookId,
            bookTitle: title,
            repository: notesRepository
        )
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }

    func showEditNote(_ note: BookNote, title: String?) {
        let vc = NoteEditorAssembly.buildEdit(
            note: note,
            bookTitle: title,
            repository: notesRepository
        )
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
