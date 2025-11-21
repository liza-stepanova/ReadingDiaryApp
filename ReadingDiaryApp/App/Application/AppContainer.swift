import Foundation

final class AppContainer {
    
    let coreDataStack: CoreDataStackProtocol
    let urlSession: URLSession
    let networkClient: NetworkClientProtocol
    let imageLoader: ImageLoaderProtocol
    let openLibraryService: OpenLibraryServiceProtocol
    let localBooksRepository: LocalBooksRepositoryProtocol
    let notesRepository: NotesRepositoryProtocol
    let themeService: ThemeServiceProtocol

    init(themeService: ThemeServiceProtocol) {
        coreDataStack = CoreDataStack()
        urlSession = URLSession.shared
        networkClient = NetworkClient(dependencies: .init(session: urlSession))
        imageLoader = ImageLoader(dependencies: .init(client: networkClient))
        openLibraryService = OpenLibraryService(dependencies: .init(client: networkClient))
        localBooksRepository = CoreDataLocalBooksRepository(dependencies: .init(stack: coreDataStack))
        notesRepository = CoreDataNotesRepository(dependencies: .init(stack: coreDataStack))
        self.themeService = themeService
    }
    
}
