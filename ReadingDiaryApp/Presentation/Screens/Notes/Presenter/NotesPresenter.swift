import Foundation

final class NotesPresenter: NotesPresenterProtocol {

    struct Dependencies {
        let interactor: NotesInteractorInput
        let router: NotesRouterInput
        let bookId: String
        let bookTitle: String?
    }

    private weak var view: NotesViewProtocol?
    private let interactor: NotesInteractorInput
    private let router: NotesRouterInput
    
    private let bookId: String
    private let bookTitle: String?

    private var notes: [BookNote] = []
    private var viewModels: [NoteCellViewModel] = []

    var numberOfNotes: Int { viewModels.count }

    init(dependencies: Dependencies) {
        self.interactor = dependencies.interactor
        self.router = dependencies.router
        self.bookId = dependencies.bookId
        self.bookTitle = dependencies.bookTitle
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
    
    func didTapAdd() {
        router.showAddNote(for: bookId, title: bookTitle)
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
