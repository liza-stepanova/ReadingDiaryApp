import Foundation

struct BookNote: Hashable {
    
    let id: String
    let bookId: String
    var text: String

    let createdAt: Date
    var updatedAt: Date?

    init(id: String = UUID().uuidString,
         bookId: String,
         text: String,
         createdAt: Date = Date(),
         updatedAt: Date? = nil
    ) {
        self.id = id
        self.bookId = bookId
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(entity: BookNoteEntity) {
        self.id = entity.noteId ?? ""
        self.bookId = entity.book?.bookId ?? ""
        self.text = entity.text ?? ""
        self.createdAt = entity.createdAt ?? Date()
        self.updatedAt = entity.updatedAt
    }
    
}
