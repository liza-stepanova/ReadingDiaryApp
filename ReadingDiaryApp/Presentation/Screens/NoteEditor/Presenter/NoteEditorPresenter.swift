final class NoteEditorPresenter: NoteEditorPresenterProtocol {

    enum Mode {
        case create(bookId: String, bookTitle: String?)
        case edit(note: BookNote)
    }

    struct Dependencies {
        let interactor: NoteEditorInteractorInput
        let mode: Mode
    }

    private weak var view: NoteEditorViewProtocol?
    private let interactor: NoteEditorInteractorInput
    private let mode: Mode

    init(dependencies: Dependencies) {
        self.interactor = dependencies.interactor
        self.mode = dependencies.mode
    }

    func setViewController(_ view: NoteEditorViewProtocol) {
        self.view = view
    }

    func viewDidLoad() {
        switch mode {
        case .create:
            view?.setInitialState(text: nil)
        case .edit(let note):
            view?.setInitialState(text: note.text)
        }
    }

    func didTapSave(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            view?.showError(message: "Текст записи не может быть пустым")
            return
        }

        switch mode {
        case .create:
            interactor.createNote(text: trimmed)
        case .edit(let note):
            interactor.updateNote(noteId: note.id, text: trimmed)
        }
    }
    
}

extension NoteEditorPresenter: NoteEditorInteractorOutput {

    func didCreateNote() {
        view?.close()
    }

    func didFailCreateNote(_ error: Error) {
        view?.showError(message: error.localizedDescription)
    }

    func didUpdateNote() {
        view?.close()
    }

    func didFailUpdateNote(_ error: Error) {
        view?.showError(message: error.localizedDescription)
    }
    
}
