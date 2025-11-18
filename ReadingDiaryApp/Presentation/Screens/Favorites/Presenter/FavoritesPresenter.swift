import Foundation

final class FavoritesPresenter: FavoritesPresenterProtocol {
    
    struct Dependencies {
        let interactor: FavoritesInteractorInput
    }

    private weak var view: FavoritesViewProtocol?
    private let interactor: FavoritesInteractorInput

    private var favoriteBooks: [LocalBook] = []
    private var viewModels: [BookCellViewModel] = []

    var numberOfItems: Int { viewModels.count }

    init(dependencies: Dependencies) {
        self.interactor = dependencies.interactor
    }
    
    func setViewController(view: FavoritesViewProtocol) {
        self.view = view
    }
    
}
