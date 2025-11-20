import Foundation
import CoreData

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

    func fetchNotes(for bookId: String, sort: NotesSortOption = .manual, completion: @escaping (Result<[BookNote], Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let request: NSFetchRequest<BookNoteEntity> = BookNoteEntity.fetchRequest()
                request.predicate = NSPredicate(format: "book.bookId == %@", bookId)

                let sortDescriptor: NSSortDescriptor
                switch sort {
                case .createdAt:
                    sortDescriptor = NSSortDescriptor(key: #keyPath(BookNoteEntity.createdAt), ascending: false)
                case .updatedAt:
                    sortDescriptor = NSSortDescriptor(key: #keyPath(BookNoteEntity.updatedAt), ascending: false)
                case .manual:
                    sortDescriptor = NSSortDescriptor(key: #keyPath(BookNoteEntity.orderIndex), ascending: true)
                }
                
                request.sortDescriptors = [sortDescriptor]
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
                
                entity.orderIndex = try self.nextOrderIndex(for: bookEntity, in: self.context)

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
                
                if entity.orderIndex == 0 {
                    if let book = entity.book {
                        entity.orderIndex = try self.nextOrderIndex(for: book, in: self.context)
                    }
                }

                self.fill(entity: entity, with: note)
                try self.saveIfNeeded(self.context)
                self.callbackQueue.async { completion(.success(())) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }

    func updateText(noteId: String, newText: String, updatedAt: Date, completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    func updateOrder(for bookId: String, orderedNoteIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                guard !orderedNoteIds.isEmpty else {
                    self.callbackQueue.async { completion(.success(())) }
                    return
                }

                let request: NSFetchRequest<BookNoteEntity> = BookNoteEntity.fetchRequest()
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "book.bookId == %@", bookId),
                    NSPredicate(format: "noteId IN %@", orderedNoteIds)
                ])

                let entities = try self.context.fetch(request)

                let map: [String: BookNoteEntity] = Dictionary(
                    uniqueKeysWithValues: entities.compactMap { entity in
                        guard let id = entity.noteId else { return nil }
                        return (id, entity)
                    }
                )

                for (index, noteId) in orderedNoteIds.enumerated() {
                    map[noteId]?.orderIndex = Int64(index)
                }

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
    
    func nextOrderIndex(for book: LocalBookEntity, in context: NSManagedObjectContext) throws -> Int64 {
        let request: NSFetchRequest<BookNoteEntity> = BookNoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "book == %@", book)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(BookNoteEntity.orderIndex), ascending: false)
        ]
        request.fetchLimit = 1

        if let last = try context.fetch(request).first {
            return last.orderIndex + 1
        } else {
            return 0
        }
    }
    
}
