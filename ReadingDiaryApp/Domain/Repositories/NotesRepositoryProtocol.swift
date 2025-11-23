import Foundation

protocol NotesRepositoryProtocol {
    
    func fetchNotes(for bookId: String, sort: NotesSortOption, completion: @escaping (Result<[BookNote], Error>) -> Void)
    func fetchRecentNotes(limit: Int, completion: @escaping (Result<[BookNote], Error>) -> Void)
    
    func add(_ note: BookNote, completion: @escaping (Result<Void, Error>) -> Void)
    func upsert(_ note: BookNote, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(noteId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteAllNotes(for bookId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func updateText(noteId: String, newText: String, updatedAt: Date, completion: @escaping (Result<Void, Error>) -> Void)
    func updateOrder(for bookId: String, orderedNoteIds: [String], completion: @escaping (Result<Void, Error>) -> Void)
    func hasNotes(for bookId: String, completion: @escaping (Result<Bool, Error>) -> Void)
    
}
