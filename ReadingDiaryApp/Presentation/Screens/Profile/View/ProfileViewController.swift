import UIKit

final class ProfileViewController: UIViewController {
    
    struct Dependencies {
        let presenter: ProfilePresenterProtocol
    }
    
    private let presenter: ProfilePresenterProtocol

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStack = UIStackView()
    
    private let headerView = ProfileHeaderView()
    
    private let statsSectionView = ProfileStatsSectionView()
    private let lastFinishedSectionView = ProfileSingleBookSectionView(title: "Последняя прочитанная")
    private let currentReadingSectionView = ProfileSingleBookSectionView(title: "Читаю сейчас")
    
    private let themeSectionView = ProfileThemeSectionView()

    init(dependencies: Dependencies) {
        self.presenter = dependencies.presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Профиль"
        
        setupLayout()
        setupActions()
        
        presenter.setViewController(self)
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
}

private extension ProfileViewController {
    
    func setupLayout() {
        setupScrollView()
        setupMainStack()
        setupSections()
    }
    
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    func setupMainStack() {
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.spacing = UIConstants.Layout.Spacing.large
        
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.Layout.Spacing.large),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.Layout.Spacing.large)
        ])
    }
    
    func setupSections() {
        mainStack.addArrangedSubview(headerView)
        mainStack.addArrangedSubview(statsSectionView)
        mainStack.addArrangedSubview(lastFinishedSectionView)
        mainStack.addArrangedSubview(currentReadingSectionView)
        mainStack.addArrangedSubview(themeSectionView)
    }
    
    func setupActions() {
        themeSectionView.onThemeChanged = { [weak self] index in
            self?.presenter.didSelectThemeSegment(at: index)
        }
    }
    
}

extension ProfileViewController: ProfileViewProtocol {
    
    func showProfile(_ viewModel: ProfileViewModel) {
        headerView.configure(name: viewModel.userName)
        
        statsSectionView.configure(doneCountText: viewModel.doneCountText,
                                   favoritesCountText: viewModel.favoritesCountText,
                                   readingCountText: viewModel.readingCountText)
      
        let lastTitle: String? = {
            guard let title = viewModel.lastFinishedTitle, !title.isEmpty else { return nil }
            if let author = viewModel.lastFinishedAuthor, !author.isEmpty {
                return "\(title) - \(author)"
            }
            return title
        }()
        lastFinishedSectionView.configure(bookTitle: lastTitle)
        
        let currentTitle: String? = {
            guard let title = viewModel.currentReadingTitle, !title.isEmpty else { return nil }
            if let author = viewModel.currentReadingAuthor, !author.isEmpty {
                return "\(title) - \(author)"
            }
            return title
        }()
        currentReadingSectionView.configure(bookTitle: currentTitle)
    }
    
    func setSelectedThemeIndex(_ index: Int) {
        themeSectionView.setSelectedIndex(index)
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
