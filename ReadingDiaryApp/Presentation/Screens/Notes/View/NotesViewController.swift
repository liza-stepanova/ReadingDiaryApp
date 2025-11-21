import UIKit

final class NotesViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private var notes: [NoteCellViewModel] = NotesMocks.sampleNotes()
    
    private let bookTitle: String?
    
    init(bookTitle: String? = nil) {
        self.bookTitle = bookTitle
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
    }
}

private extension NotesViewController {
    
    func setupNavigationBar() {
        // добавить запись
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
//        tableView.dropDelegate = self
            
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
    
}

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.identifier, for: indexPath) as? NoteTableViewCell
        else { return UITableViewCell() }
                
        let model = notes[indexPath.row]
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moved = notes.remove(at: sourceIndexPath.row)
        notes.insert(moved, at: destinationIndexPath.row)
    }
    
}

extension NotesViewController: UITableViewDragDelegate, UITableViewDropDelegate {

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let note = notes[indexPath.row]
        let itemProvider = NSItemProvider(object: note.text as NSString)

        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = note

        return [dragItem]
    }

    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.localDragSession != nil
    }

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return UITableViewDropProposal(operation: .forbidden)
        }
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
            return
        }

        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath,
               let note = item.dragItem.localObject as? NoteCellViewModel {

                tableView.performBatchUpdates({
                    notes.remove(at: sourceIndexPath.row)
                    notes.insert(note, at: destinationIndexPath.row)

                    tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
                }, completion: nil)

                coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
            }
        }
    }
}


enum NotesMocks {
    static func sampleNotes() -> [NoteCellViewModel] {
        return [
            NoteCellViewModel(
                id: "1",
                text: "Очень понравился образ главного героя. Есть пара интересных цитат, надо потом выписать для рецензии.",
                dateString: "12.11.2025"
            ),
            NoteCellViewModel(
                id: "2",
                text: "Сюжет провисает в середине — главы 7–9 можно было бы сократить. Но концовка вытягивает.",
                dateString: "13.11.2025"
            ),
            NoteCellViewModel(
                id: "3",
                text: "Цитата: «Мы ответственны за тех, кого приручили» — отлично подойдёт для поста в читательский дневник.",
                dateString: "14.11.2025"
            ),
            NoteCellViewModel(
                id: "4",
                text: "Интересное сравнение с предыдущей книгой автора: здесь повествование от первого лица, читается живее.",
                dateString: "15.11.2025"
            )
        ]
    }
}
