import UIKit

protocol MyBooksModuleFactoryProtocol {
    
    func makeMyBooks() -> UIViewController
    
}

final class MyBooksModuleFactory: MyBooksModuleFactoryProtocol {
    
    private let repository: LocalBooksRepositoryProtocol
    private let notesRepository: NotesRepositoryProtocol
    
    init(repository: LocalBooksRepositoryProtocol, notesRepository: NotesRepositoryProtocol) {
        self.repository = repository
        self.notesRepository = notesRepository
    }
    
    func makeMyBooks() -> UIViewController {
        MyBooksAssembly.build(repository: repository, notesRepository: notesRepository)
    }
    
}
