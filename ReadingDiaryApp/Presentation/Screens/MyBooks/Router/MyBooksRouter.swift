import UIKit

final class MyBooksRouter: MyBooksRouterInput {
    
    struct Dependencies {
        let notesFactory: NotesModuleFactoryProtocol
    }
    
    weak var viewController: UIViewController?
    
    private let notesFactory: NotesModuleFactoryProtocol
    
    init(dependencies: Dependencies) {
        self.notesFactory = dependencies.notesFactory
    }
    
    func showNotes(for book: LocalBook) {
        let notesVC = notesFactory.makeNotes(bookId: book.id, bookTitle: book.title)
        viewController?.navigationController?.pushViewController(notesVC, animated: true)
    }
    
}
