import Foundation

final class NoteEditorInteractor: NoteEditorInteractorInput {

    struct Dependencies {
        let repository: NotesRepositoryProtocol
        let bookId: String
    }

    weak var output: NoteEditorInteractorOutput?

    private let repository: NotesRepositoryProtocol
    private let bookId: String

    init(dependencies: Dependencies) {
        self.repository = dependencies.repository
        self.bookId = dependencies.bookId
    }

    func createNote(text: String) {
        let now = Date()
        let note = BookNote(
            id: UUID().uuidString,
            bookId: bookId,
            text: text,
            createdAt: now,
            updatedAt: now
        )

        repository.add(note) { [weak self] result in
            switch result {
            case .success:
                self?.output?.didCreateNote()
            case .failure(let error):
                self?.output?.didFailCreateNote(error)
            }
        }
    }

    func updateNote(noteId: String, text: String) {
        repository.updateText(noteId: noteId, newText: text, updatedAt: Date()) { [weak self] result in
            switch result {
            case .success:
                self?.output?.didUpdateNote()
            case .failure(let error):
                self?.output?.didFailUpdateNote(error)
            }
        }
    }
    
}
