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
        let editorVC = UIViewController()
        viewController?.navigationController?.pushViewController(editorVC, animated: true)
    }
}
