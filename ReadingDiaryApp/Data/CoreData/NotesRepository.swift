import Foundation
import CoreData

protocol NotesRepositoryProtocol {
    
    func fetchNotes(for bookId: String, completion: @escaping (Result<[BookNote], Error>) -> Void)
    func fetchRecentNotes(limit: Int, completion: @escaping (Result<[BookNote], Error>) -> Void)
    
    func add(_ note: BookNote, completion: @escaping (Result<Void, Error>) -> Void)
    func upsert(_ note: BookNote, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(noteId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteAllNotes(for bookId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func updateText(noteId: String,
                    newText: String,
                    updatedAt: Date,
                    completion: @escaping (Result<Void, Error>) -> Void)
}

enum NotesRepositoryError: Error {
    case notFound
    case bookNotFound
}

final class CoreDataNotesRepository: NotesRepositoryProtocol {

    struct Dependencies {
        let stack: CoreDataStackProtocol
        let callbackQueue: DispatchQueue = .main
    }

    private let stack: CoreDataStackProtocol
    private let callbackQueue: DispatchQueue

    private lazy var context: NSManagedObjectContext = {
        let context = stack.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
        return context
    }()

    init(dependencies: Dependencies) {
        self.stack = dependencies.stack
        self.callbackQueue = dependencies.callbackQueue

        stack.viewContext.automaticallyMergesChangesFromParent = true
        stack.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }

    func fetchNotes(for bookId: String, completion: @escaping (Result<[BookNote], Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let request: NSFetchRequest<BookNoteEntity> = BookNoteEntity.fetchRequest()
                request.predicate = NSPredicate(format: "book.bookId == %@", bookId)

                let byCreated = NSSortDescriptor(key: #keyPath(BookNoteEntity.createdAt), ascending: false)
                request.sortDescriptors = [byCreated]
                request.fetchBatchSize = 50

                let entities = try self.context.fetch(request)
                let notes = entities.map(BookNote.init(entity:))
                self.callbackQueue.async { completion(.success(notes)) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }

    func fetchRecentNotes(limit: Int, completion: @escaping (Result<[BookNote], Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let request: NSFetchRequest<BookNoteEntity> = BookNoteEntity.fetchRequest()
                let byCreated = NSSortDescriptor(key: #keyPath(BookNoteEntity.createdAt), ascending: false)
                request.sortDescriptors = [byCreated]
                request.fetchLimit = max(1, limit)

                let entities = try self.context.fetch(request)
                let notes = entities.map(BookNote.init(entity:))
                self.callbackQueue.async { completion(.success(notes)) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }

    func add(_ note: BookNote, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                guard let bookEntity = try self.findBook(by: note.bookId, in: self.context) else {
                    throw NotesRepositoryError.bookNotFound
                }

                let entity = BookNoteEntity(context: self.context)
                self.fill(entity: entity, with: note)
                entity.book = bookEntity

                try self.saveIfNeeded(self.context)
                self.callbackQueue.async { completion(.success(())) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }

    func upsert(_ note: BookNote, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let entity = try self.findOrInsertNote(by: note.id, in: self.context)

                if entity.book == nil {
                    guard let bookEntity = try self.findBook(by: note.bookId, in: self.context) else {
                        throw NotesRepositoryError.bookNotFound
                    }
                    entity.book = bookEntity
                }

                self.fill(entity: entity, with: note)
                try self.saveIfNeeded(self.context)
                self.callbackQueue.async { completion(.success(())) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }

    func updateText(noteId: String,
                    newText: String,
                    updatedAt: Date,
                    completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let entity = try self.findRequiredNote(by: noteId, in: self.context)
                entity.text = newText
                entity.updatedAt = updatedAt
                try self.saveIfNeeded(self.context)
                self.callbackQueue.async { completion(.success(())) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }

    func delete(noteId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                if let entity = try self.findNote(by: noteId, in: self.context) {
                    self.context.delete(entity)
                    try self.saveIfNeeded(self.context)
                }
                self.callbackQueue.async { completion(.success(())) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }

    func deleteAllNotes(for bookId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let request: NSFetchRequest<BookNoteEntity> = BookNoteEntity.fetchRequest()
                request.predicate = NSPredicate(format: "book.bookId == %@", bookId)

                let entities = try self.context.fetch(request)
                entities.forEach { self.context.delete($0) }
                try self.saveIfNeeded(self.context)
                self.callbackQueue.async { completion(.success(())) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }
    
}

private extension CoreDataNotesRepository {
    
    func findBook(by bookId: String, in context: NSManagedObjectContext) throws -> LocalBookEntity? {
        let request: NSFetchRequest<LocalBookEntity> = LocalBookEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "bookId == %@", bookId)
        
        return try context.fetch(request).first
    }

    func findNote(by noteId: String, in context: NSManagedObjectContext) throws -> BookNoteEntity? {
        let request: NSFetchRequest<BookNoteEntity> = BookNoteEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "noteId == %@", noteId)
        
        return try context.fetch(request).first
    }

    func findRequiredNote(by noteId: String, in context: NSManagedObjectContext) throws -> BookNoteEntity {
        if let entity = try findNote(by: noteId, in: context) { return entity }
        throw NotesRepositoryError.notFound
    }

    func findOrInsertNote(by noteId: String, in context: NSManagedObjectContext) throws -> BookNoteEntity {
        if let existing = try findNote(by: noteId, in: context) { return existing }
        let entity = BookNoteEntity(context: context)
        entity.noteId = noteId
        
        return entity
    }

    func fill(entity: BookNoteEntity, with model: BookNote) {
        entity.noteId = model.id
        entity.text = model.text
        entity.createdAt = model.createdAt
        entity.updatedAt = model.updatedAt
    }

    func saveIfNeeded(_ context: NSManagedObjectContext) throws {
        if context.hasChanges { try context.save() }
    }
    
}
