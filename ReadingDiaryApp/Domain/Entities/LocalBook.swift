import Foundation

struct LocalBook: Hashable {
    
    let id: String
    let title: String
    let author: String
    let coverId: Int?
    let firstPublishYear: Int?
    let coverImageData: Data?
    var readingStatus: ReadingStatus
    var isFavorite: Bool
    let dateAdded: Date
    
    init(from book: Book, status: ReadingStatus = .none, isFavorite: Bool = false) {
        self.id = book.id
        self.title = book.title
        self.author = book.author
        self.coverId = book.coverId
        self.firstPublishYear = book.firstPublishYear
        self.coverImageData = nil
        self.readingStatus = status
        self.isFavorite = isFavorite
        self.dateAdded = Date()
    }
    
}
