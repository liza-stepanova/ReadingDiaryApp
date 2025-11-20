import UIKit

enum CatalogAssembly {
    
    static func build(service: OpenLibraryServiceProtocol,
                      imageLoader: ImageLoaderProtocol,
                      localBooksRepository: LocalBooksRepositoryProtocol) -> UIViewController {

        let interactor = CatalogInteractor(dependencies: .init(
            service: service,
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
