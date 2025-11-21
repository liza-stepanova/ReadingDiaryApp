import Foundation

final class NotesPresenter: NotesPresenterProtocol {

    struct Dependencies {
        let interactor: NotesInteractorInput
    }

    private weak var view: NotesViewProtocol?
    private let interactor: NotesInteractorInput

    private var notes: [BookNote] = []
    private var viewModels: [NoteCellViewModel] = []

    var numberOfNotes: Int { viewModels.count }

    init(dependencies: Dependencies) {
        self.interactor = dependencies.interactor
    }

    func setViewController(_ view: NotesViewProtocol) {
        self.view = view
    }

    func viewDidLoad() {
        interactor.fetchNotes()
    }

    func noteViewModel(at index: Int) -> NoteCellViewModel {
        viewModels[index]
    }

    func didMoveNote(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex,
              sourceIndex >= 0, sourceIndex < notes.count,
              destinationIndex >= 0, destinationIndex < notes.count
        else { return }

        let movedNote = notes.remove(at: sourceIndex)
        notes.insert(movedNote, at: destinationIndex)

        let movedVM = viewModels.remove(at: sourceIndex)
        viewModels.insert(movedVM, at: destinationIndex)

        let orderedIds = notes.map { $0.id }
        interactor.updateOrder(noteIdsInOrder: orderedIds)
    }
}

extension NotesPresenter: NotesInteractorOutput {

    func didLoadNotes(_ notes: [BookNote]) {
        self.notes = notes
        self.viewModels = notes.map(makeViewModel(from:))
        view?.showEmptyState(viewModels.isEmpty)
        view?.reloadData()
    }

    func didFailLoadNotes(_ error: Error) {
        view?.showError(message: error.localizedDescription)
    }

    func didFailUpdateOrder(_ error: Error) {
        view?.showError(message: error.localizedDescription)
    }
}

private extension NotesPresenter {

    func makeViewModel(from note: BookNote) -> NoteCellViewModel {
        let dateString = dateFormatter.string(from: note.createdAt)
        return NoteCellViewModel(
            id: note.id,
            text: note.text,
            dateString: dateString
        )
    }

    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy"
        return df
    }
}
