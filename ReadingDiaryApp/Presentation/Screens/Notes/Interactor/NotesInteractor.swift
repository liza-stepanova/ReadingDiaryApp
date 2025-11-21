import Foundation

final class NotesInteractor: NotesInteractorInput {

    struct Dependencies {
        let repository: NotesRepositoryProtocol
        let bookId: String
    }

    weak var output: NotesInteractorOutput?

    private let repository: NotesRepositoryProtocol
    private let bookId: String

    init(dependencies: Dependencies) {
        self.repository = dependencies.repository
        self.bookId = dependencies.bookId
    }

    func fetchNotes() {
        repository.fetchNotes(for: bookId, sort: .manual) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let notes):
                self.output?.didLoadNotes(notes)
            case .failure(let error):
                self.output?.didFailLoadNotes(error)
            }
        }
    }

    func updateOrder(noteIdsInOrder: [String]) {
        repository.updateOrder(for: bookId, orderedNoteIds: noteIdsInOrder) { [weak self] result in
            guard let self else { return }
            if case let .failure(error) = result {
                self.output?.didFailUpdateOrder(error)
            }
        }
    }
    
}
