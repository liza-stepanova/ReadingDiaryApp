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
    
    init(from book: Book, status: ReadingStatus = .none, isFavorite: Bool = false, coverImageData: Data? = nil) {
        self.id = book.id
        self.title = book.title
        self.author = book.author
        self.coverId = book.coverId
        self.firstPublishYear = book.firstPublishYear
        self.coverImageData = coverImageData
        self.readingStatus = status
        self.isFavorite = isFavorite
        self.dateAdded = Date()
    }
    
    init(entity: LocalBookEntity) {
        self.id = entity.bookId ?? ""
        self.title = entity.title ?? ""
        self.author = entity.author ?? ""
        self.coverId = Int(entity.coverId)
        self.firstPublishYear = Int(entity.firstPublishYear)
        self.coverImageData = entity.coverImageData
        self.readingStatus = ReadingStatus(rawValue: Int(entity.readingStatus)) ?? .none
        self.isFavorite = entity.isFavorite
        self.dateAdded = entity.dateAdded ?? Date()
    }
    
}
