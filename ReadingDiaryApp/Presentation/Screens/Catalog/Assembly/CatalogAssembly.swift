import UIKit

enum CatalogAssembly {
    
    static func build() -> UIViewController {
        let session = URLSession.shared
        let networkClient = NetworkClient(dependencies: .init(session: session))

        let imageLoader = ImageLoader(dependencies: .init(client: networkClient))
        let openLibrary = OpenLibraryService(dependencies: .init(client: networkClient))
        let localBooksRepository: LocalBooksRepositoryProtocol = CoreDataLocalBooksRepository(dependencies: .init(stack: CoreDataStack()))

        let interactor = CatalogInteractor(dependencies: .init(
            service: openLibrary,
            imageLoader: imageLoader,
            localBooksRepository: localBooksRepository)
        )

        let presenter = CatalogPresenter(dependencies: .init(interactor: interactor))

        let view = CatalogViewController(dependencies: .init(presenter: presenter))

        interactor.output = presenter
        presenter.setViewController(view: view)

        return view
    }
    
}
