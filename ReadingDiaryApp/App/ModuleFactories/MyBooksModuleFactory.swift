import UIKit

protocol MyBooksModuleFactoryProtocol {
    
    func makeMyBooks() -> UIViewController
    
}

final class MyBooksModuleFactory: MyBooksModuleFactoryProtocol {
    
    private let repository: LocalBooksRepositoryProtocol
    
    init(repository: LocalBooksRepositoryProtocol) {
        self.repository = repository
    }
    
    func makeMyBooks() -> UIViewController {
        MyBooksAssembly.build(repository: repository)
    }
    
}
