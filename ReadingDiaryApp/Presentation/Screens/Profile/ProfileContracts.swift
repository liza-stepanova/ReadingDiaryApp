import UIKit

protocol ProfileViewProtocol: AnyObject {
    
    func showProfile(_ viewModel: ProfileViewModel)
    func setSelectedThemeIndex(_ index: Int)
    func showError(message: String)
    
}

protocol ProfilePresenterProtocol: AnyObject {
    
    func setViewController(_ view: ProfileViewProtocol)
    func viewDidLoad()
    func viewWillAppear()
    func didSelectThemeSegment(at index: Int)
    
}

protocol ProfileInteractorInput: AnyObject {
    
    func loadProfile()
    func getCurrentTheme() -> AppTheme
    func updateTheme(_ theme: AppTheme)
    
}

protocol ProfileInteractorOutput: AnyObject {
    
    func didLoadProfileStats(
        favorites: [LocalBook],
        reading: [LocalBook],
        done: [LocalBook]
    )
    func didFailProfile(with error: Error)
    
}
