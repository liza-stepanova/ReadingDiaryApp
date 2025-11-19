import UIKit

enum BookGridLayoutFactory {
    
    static func makeLayout(config: BookGridLayoutConfig = .default) -> UICollectionViewCompositionalLayout {
       UICollectionViewCompositionalLayout { _, _ in
           let fraction = 1.0 / CGFloat(max(1, config.columns))

           let itemSize = NSCollectionLayoutSize(
               widthDimension: .fractionalWidth(fraction),
               heightDimension: .estimated(config.estimatedHeight)
           )
           let item = NSCollectionLayoutItem(layoutSize: itemSize)
           item.contentInsets = .init(
               top: config.itemVInset,
               leading: config.itemHInset,
               bottom: config.itemVInset,
               trailing: config.itemHInset
           )

           let groupSize = NSCollectionLayoutSize(
               widthDimension: .fractionalWidth(1.0),
               heightDimension: .estimated(config.estimatedHeight)
           )
           
           let group = NSCollectionLayoutGroup.horizontal(
               layoutSize: groupSize,
               subitems: Array(repeating: item, count: max(1, config.columns))
           )

           let section = NSCollectionLayoutSection(group: group)
           if config.useLayoutMargins {
               section.contentInsetsReference = .layoutMargins
               section.contentInsets = .zero
           } else {
               section.contentInsets = config.sectionInsets
           }
           section.interGroupSpacing = config.rowSpacing
           return section
       }
   }
    
}
