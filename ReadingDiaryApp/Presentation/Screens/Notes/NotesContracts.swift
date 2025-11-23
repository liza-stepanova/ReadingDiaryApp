import Foundation

protocol NotesPresenterProtocol: AnyObject {
    
    var numberOfNotes: Int { get }

    func setViewController(_ view: NotesViewProtocol)
    func viewDidLoad()
    func viewWillAppear()

    func noteViewModel(at index: Int) -> NoteCellViewModel
    func didMoveNote(from sourceIndex: Int, to destinationIndex: Int)
    func didTapAdd()
    func didSelectNote(at index: Int) 
    
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

protocol NotesRouterInput: AnyObject {
    
    func showAddNote(for bookId: String, title: String?)
    func showEditNote(_ note: BookNote, title: String?)
    
}
