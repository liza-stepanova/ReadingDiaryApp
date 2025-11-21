import Foundation

final class ProfileInteractor: ProfileInteractorInput {
    
    struct Dependencies {
        let booksRepository: LocalBooksRepositoryProtocol
        let themeService: ThemeServiceProtocol
    }
    
    weak var output: ProfileInteractorOutput?
    
    private let booksRepository: LocalBooksRepositoryProtocol
    private let themeService: ThemeServiceProtocol
    
    init(dependencies: Dependencies) {
        self.booksRepository = dependencies.booksRepository
        self.themeService = dependencies.themeService
    }
    
    func loadProfile() {
        let group = DispatchGroup()
        
        var favorites: [LocalBook]?
        var reading: [LocalBook]?
        var done: [LocalBook]?
        
        var capturedError: Error?
        
        group.enter()
        booksRepository.fetchFavorites { result in
            switch result {
            case .success(let items):
                favorites = items
            case .failure(let error):
                capturedError = capturedError ?? error
            }
            group.leave()
        }
        
        group.enter()
        booksRepository.fetchMyBooks(filter: .reading) { result in
            switch result {
            case .success(let items):
                reading = items
            case .failure(let error):
                capturedError = capturedError ?? error
            }
            group.leave()
        }
        
        group.enter()
        booksRepository.fetchMyBooks(filter: .done) { result in
            switch result {
            case .success(let items):
                done = items
            case .failure(let error):
                capturedError = capturedError ?? error
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            
            if let error = capturedError {
                self.output?.didFailProfile(with: error)
                return
            }
            
            self.output?.didLoadProfileStats(
                favorites: favorites ?? [],
                reading: reading ?? [],
                done: done ?? []
            )
        }
    }

    func getCurrentTheme() -> AppTheme {
        themeService.currentTheme
    }
    
    func updateTheme(_ theme: AppTheme) {
        themeService.apply(theme: theme)
    }
    
}
