import Foundation

protocol NotesPresenterProtocol: AnyObject {
    
    var numberOfNotes: Int { get }

    func setViewController(_ view: NotesViewProtocol)
    func viewDidLoad()

    func noteViewModel(at index: Int) -> NoteCellViewModel
    func didMoveNote(from sourceIndex: Int, to destinationIndex: Int)
    
}

protocol NotesViewProtocol: AnyObject {
    
    func reloadData()
    func showEmptyState(_ flag: Bool)
    func showError(message: String)
    
}

protocol NotesInteractorInput: AnyObject {
    
    func fetchNotes()
    func updateOrder(noteIdsInOrder: [String])
    
}

protocol NotesInteractorOutput: AnyObject {
    
    func didLoadNotes(_ notes: [BookNote])
    func didFailLoadNotes(_ error: Error)
    func didFailUpdateOrder(_ error: Error)
    
}
