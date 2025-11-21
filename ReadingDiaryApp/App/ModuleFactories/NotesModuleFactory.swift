import UIKit

protocol NotesModuleFactoryProtocol {
    
    func makeNotes(bookId: String, bookTitle: String?) -> UIViewController
    
}

final class NotesModuleFactory: NotesModuleFactoryProtocol {
    
    private let notesRepository: NotesRepositoryProtocol
    
    init(notesRepository: NotesRepositoryProtocol) {
        self.notesRepository = notesRepository
    }
    
    func makeNotes(bookId: String, bookTitle: String?) -> UIViewController {
        return NotesAssembly.build(
            bookId: bookId,
            bookTitle: bookTitle,
            notesRepository: notesRepository
        )
    }
}

