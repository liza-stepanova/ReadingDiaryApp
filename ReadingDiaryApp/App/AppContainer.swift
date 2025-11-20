import Foundation

final class AppContainer {
    
    let coreDataStack: CoreDataStackProtocol
    let urlSession: URLSession
    let networkClient: NetworkClient
    let imageLoader: ImageLoader
    let openLibrary: OpenLibraryService

    init() {
        coreDataStack = CoreDataStack()
        urlSession = URLSession.shared
        networkClient = NetworkClient(dependencies: .init(session: urlSession))
        imageLoader = ImageLoader(dependencies: .init(client: networkClient))
        openLibrary = OpenLibraryService(dependencies: .init(client: networkClient))
    }
    
}
