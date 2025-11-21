import UIKit

final class BookGridView: UIView {
    
    let collectionView: UICollectionView
    
    let bottomSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    init(config: BookGridLayoutConfig = .default) {
        let layout = BookGridLayoutFactory.makeLayout(config: config)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        setupCollectionView(collectionView: collectionView, config: config)
        setupBottomSpinner()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func setupCollectionView(collectionView: UICollectionView, config: BookGridLayoutConfig) {
        translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.clipsToBounds = false
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: BookCell.identifier)

        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupBottomSpinner() {
        addSubview(bottomSpinner)
        NSLayoutConstraint.activate([
            bottomSpinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomSpinner.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -UIConstants.Layout.Inset.vertical)
        ])

        collectionView.contentInset.bottom = UIConstants.BookGrid.Spacing.bottomPadding
        collectionView.verticalScrollIndicatorInsets.bottom = UIConstants.BookGrid.Spacing.bottomPadding
    }
    
}
