import UIKit

struct BookCellViewModel: Hashable {
    
    let title: String
    let author: String
    let cover: UIImage?
    let status: ReadingStatus
    let isFavorite: Bool
    
}
