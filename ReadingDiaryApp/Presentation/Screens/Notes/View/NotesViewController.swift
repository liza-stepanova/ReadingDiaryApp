import UIKit

final class NotesViewController: UIViewController {
    
    struct Dependencies {
        let presenter: NotesPresenterProtocol
        let bookTitle: String?
    }
    
    private let presenter: NotesPresenterProtocol
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "У вас ещё нет записей"
        label.textAlignment = .center
        label.textColor = .secondaryAccent
        label.numberOfLines = 0
        
        return label
    }()
    
    private let bookTitle: String?
    
    init(dependencies: Dependencies) {
        self.presenter = dependencies.presenter
        self.bookTitle = dependencies.bookTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        view.backgroundColor = .systemBackground
        title = bookTitle ?? "Записи"
            
        setupNavigationBar()
        setupTableView()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
}

private extension NotesViewController {
    
    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationController?.navigationBar.tintColor = .primaryAccent
        navigationItem.backButtonTitle = ""
    }
    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
            
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
            
        tableView.register(
            NoteTableViewCell.self,
            forCellReuseIdentifier: NoteTableViewCell.identifier
        )
            
        view.addSubview(tableView)
            
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func addButtonTapped() {
        presenter.didTapAdd()
    }
    
}

extension NotesViewController: NotesViewProtocol {

    func reloadData() {
        tableView.reloadData()
    }

    func showEmptyState(_ flag: Bool) {
        tableView.backgroundView = flag ? emptyLabel : nil
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfNotes
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.identifier, for: indexPath) as? NoteTableViewCell
        else { return UITableViewCell() }
                
        let model = presenter.noteViewModel(at: indexPath.row)
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        presenter.didMoveNote(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectNote(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension NotesViewController: UITableViewDragDelegate {

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let model = presenter.noteViewModel(at: indexPath.row)
        let itemProvider = NSItemProvider(object: model.text as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = model

        return [dragItem]
    }
}
