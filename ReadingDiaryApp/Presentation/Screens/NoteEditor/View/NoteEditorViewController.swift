import UIKit

final class NoteEditorViewController: UIViewController {
    
    struct Dependencies {
        let presenter: NoteEditorPresenterProtocol
        let bookTitle: String?
    }

    private let presenter: NoteEditorPresenterProtocol
    private let bookTitle: String?

    private let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIConstants.Font.text1
        return tv
    }()

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
        title = bookTitle ?? "Запись"

        setupNavBar()
        setupTextView()
        presenter.viewDidLoad()
    }
    
}

private extension NoteEditorViewController {
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
    }

    func setupTextView() {
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.Layout.Spacing.large),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.Layout.Inset.horizontal),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.Layout.Inset.horizontal),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -UIConstants.Layout.Spacing.large)
        ])
    }

    @objc func saveTapped() {
        presenter.didTapSave(text: textView.text ?? "")
    }
    
}

extension NoteEditorViewController: NoteEditorViewProtocol {
    
    func setInitialState(text: String?) {
        textView.text = text
        textView.becomeFirstResponder()
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func close() {
        navigationController?.popViewController(animated: true)
    }
    
}
