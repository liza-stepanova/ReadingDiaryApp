import UIKit

final class BookGridView: UIView {
    
    let collectionView: UICollectionView
    
    init(config: BookGridLayoutConfig = .default) {
        let layout = BookGridLayoutFactory.makeLayout(config: config)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        setup(collectionView: collectionView, config: config)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func setup(collectionView: UICollectionView, config: BookGridLayoutConfig) {
        translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: BookCell.identifier)

        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
