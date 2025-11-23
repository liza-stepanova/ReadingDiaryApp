import UIKit

final class ProfilePresenter: ProfilePresenterProtocol {
    
    struct Dependencies {
        let interactor: ProfileInteractorInput
        let displayName: String
    }
    
    private weak var view: ProfileViewProtocol?
    private let interactor: ProfileInteractorInput
    private let displayName: String
    
    init(dependencies: Dependencies) {
        self.interactor = dependencies.interactor
        self.displayName = dependencies.displayName
    }
    
    func setViewController(_ view: ProfileViewProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        let theme = interactor.getCurrentTheme()
        view?.setSelectedThemeIndex(theme.rawValue)
        interactor.loadProfile()
    }
    
    func viewWillAppear() {
        interactor.loadProfile()
    }
    
    func didSelectThemeSegment(at index: Int) {
        guard let theme = AppTheme(rawValue: index) else { return }
        interactor.updateTheme(theme)
    }
}

extension ProfilePresenter: ProfileInteractorOutput {
    
    func didLoadProfileStats(favorites: [LocalBook], reading: [LocalBook], done: [LocalBook]) {
        let favoritesCount = favorites.count
        let readingCount = reading.count
        let doneCount = done.count
        
        let lastFinished = done.sorted { $0.dateAdded > $1.dateAdded }.first
        let currentReading = reading.sorted { $0.dateAdded > $1.dateAdded }.first
        
        let viewModel = ProfileViewModel(
            userName: displayName,
            avatar: nil,
            favoritesCountText: "\(favoritesCount)",
            readingCountText: "\(readingCount)",
            doneCountText: "\(doneCount)",
            currentReadingTitle: currentReading?.title,
            currentReadingAuthor: currentReading?.author,
            lastFinishedTitle: lastFinished?.title,
            lastFinishedAuthor: lastFinished?.author
        )
        
        view?.showProfile(viewModel)
    }
    
    func didFailProfile(with error: Error) {
        view?.showError(message: error.localizedDescription)
    }
    
}
