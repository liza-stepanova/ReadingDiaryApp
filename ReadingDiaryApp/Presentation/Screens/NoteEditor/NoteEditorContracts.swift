protocol NoteEditorViewProtocol: AnyObject {
    
    func setInitialState(text: String?)
    func showError(message: String)
    func close()
    
}

protocol NoteEditorPresenterProtocol: AnyObject {
    
    func setViewController(_ view: NoteEditorViewProtocol)
    func viewDidLoad()
    func didTapSave(text: String)
    
}

protocol NoteEditorInteractorInput: AnyObject {
    
    func createNote(text: String)
    func updateNote(noteId: String, text: String)
    
}

protocol NoteEditorInteractorOutput: AnyObject {
    
    func didCreateNote()
    func didFailCreateNote(_ error: Error)
    func didUpdateNote()
    func didFailUpdateNote(_ error: Error)
    
}
