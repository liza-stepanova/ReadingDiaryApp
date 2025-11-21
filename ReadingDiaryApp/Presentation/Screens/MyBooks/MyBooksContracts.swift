protocol MyBooksPresenterProtocol: AnyObject {
    
    func itemViewModel(at index: Int) -> BookCellViewModel
    func setViewController(view: FavoritesViewProtocol)
    
    var numberOfItems: Int { get }
    func viewDidLoad()
    func viewWillAppear()
    
    func didSelectFilter(at index: Int)
    func didChangeStatus(for index: Int, to status: ReadingStatus)
    func didToggleFavorite(for index: Int, isFavorite: Bool)
    
}

protocol MyBooksViewProtocol {
    
    func reloadData()
    func reloadItems(at indexes: [Int])
    func showEmptyState(_ flag: Bool)
    func showError(message: String)
    func setSelectedFilterIndex(_ index: Int)
    
}
