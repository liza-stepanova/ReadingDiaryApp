import UIKit

struct BookGridLayoutConfig: Equatable {
    
    let columns: Int
    let estimatedHeight: CGFloat
    let itemHInset: CGFloat
    let itemVInset: CGFloat
    let rowSpacing: CGFloat
    let sectionInsets: NSDirectionalEdgeInsets
    let useLayoutMargins: Bool

    static let `default` = BookGridLayoutConfig(
        columns: UIConstants.BookGrid.columns,
        estimatedHeight: UIConstants.BookGrid.Size.estimatedHeight,
        itemHInset: UIConstants.BookGrid.Spacing.itemHorizontal,
        itemVInset: UIConstants.BookGrid.Spacing.itemVertical,
        rowSpacing: UIConstants.BookGrid.Spacing.row,
        sectionInsets: UIConstants.BookGrid.Spacing.sectionInsets,
        useLayoutMargins: true
    )
    
}
