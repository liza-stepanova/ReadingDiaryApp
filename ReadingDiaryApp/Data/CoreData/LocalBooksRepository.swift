import Foundation
import CoreData

protocol LocalBooksRepositoryProtocol {
    
    func fetchFavorites(completion: @escaping (Result<[LocalBook], Error>) -> Void)
    func fetchMyBooks(filter: MyBooksFilter, completion: @escaping (Result<[LocalBook], Error>) -> Void)
    
    func upsert(_ book: LocalBook, completion: @escaping (Result<Void, Error>) -> Void)
    func updateStatus(bookId: String, status: ReadingStatus, completion: @escaping (Result<Void, Error>) -> Void)
    func toggleFavorite(bookId: String, isFavorite: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(bookId: String, completion: @escaping (Result<Void, Error>) -> Void)
    
    func fetch(byIDs ids: [String], completion: @escaping (Result<[String: LocalBook], Error>) -> Void)
    func updateCoverData(bookId: String, data: Data?, completion: @escaping (Result<Void, Error>) -> Void)
    
}

enum MyBooksFilter {
    case all
    case reading
    case done
}

enum FavoritesRepositoryError: Error {
    case notFound
}

final class CoreDataLocalBooksRepository: LocalBooksRepositoryProtocol {

    struct Dependencies {
        let stack: CoreDataStackProtocol
        let callbackQueue: DispatchQueue = .main
    }

    private let stack: CoreDataStackProtocol
    private let callbackQueue: DispatchQueue
    
    private lazy var context: NSManagedObjectContext = {
        return stack.newBackgroundContext()
    }()

    init(dependencies: Dependencies) {
        self.stack = dependencies.stack
        self.callbackQueue = dependencies.callbackQueue
        
        stack.viewContext.automaticallyMergesChangesFromParent = true
        stack.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }

    func fetchFavorites(completion: @escaping (Result<[LocalBook], Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let fetchRequest: NSFetchRequest<LocalBookEntity> = LocalBookEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "isFavorite == YES")
                
                let sort = NSSortDescriptor(key: #keyPath(LocalBookEntity.dateAdded), ascending: false)
                fetchRequest.sortDescriptors = [sort]

                let items = try self.context.fetch(fetchRequest)
                let models = items.map(LocalBook.init(entity:))
                self.callbackQueue.async { completion(.success(models)) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }
    
    func fetchMyBooks(filter: MyBooksFilter, completion: @escaping (Result<[LocalBook], Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let request: NSFetchRequest<LocalBookEntity> = LocalBookEntity.fetchRequest()

                let key = #keyPath(LocalBookEntity.readingStatus)
                switch filter {
                case .all:
                    let values = [ReadingStatus.reading, .done].map { Int16($0.rawValue) }.map(NSNumber.init(value:))
                    request.predicate = NSPredicate(format: "%K IN %@", key, values)
                case .reading:
                    request.predicate = NSPredicate(format: "%K == %d", key, Int16(ReadingStatus.reading.rawValue))
                case .done:
                    request.predicate = NSPredicate(format: "%K == %d", key, Int16(ReadingStatus.done.rawValue))}

                let byStatus = NSSortDescriptor(key: key, ascending: true)
                let byDate = NSSortDescriptor(key: #keyPath(LocalBookEntity.dateAdded), ascending: false)
                request.sortDescriptors = (filter == .all) ? [byStatus, byDate] : [byDate]
                request.fetchBatchSize = 50

                let entities = try self.context.fetch(request)
                let models = entities.map(LocalBook.init(entity:))
                self.callbackQueue.async { completion(.success(models)) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }

    func upsert(_ book: LocalBook, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let entity = try self.findOrInsert(by: book.id, in: self.context)
                self.fill(entity: entity, with: book)
                try self.saveIfNeeded(self.context)
                self.callbackQueue.async { completion(.success(())) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }

    func updateStatus(bookId: String, status: ReadingStatus, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let entity = try self.findRequired(by: bookId, in: self.context)
                entity.readingStatus = Int16(status.rawValue)
                if entity.bookId == nil { entity.bookId = bookId }
                try self.saveIfNeeded(self.context)
                self.callbackQueue.async { completion(.success(())) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }

    func toggleFavorite(bookId: String, isFavorite: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let entity = try self.findOrInsert(by: bookId, in: self.context)
                entity.isFavorite = isFavorite
                if entity.bookId == nil { entity.bookId = bookId }
                if entity.dateAdded == nil { entity.dateAdded = Date() }
                try self.saveIfNeeded(self.context)
                self.callbackQueue.async { completion(.success(())) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }

    func delete(bookId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let fetchRequest: NSFetchRequest<LocalBookEntity> = LocalBookEntity.fetchRequest()
                fetchRequest.fetchLimit = 1
                fetchRequest.predicate = NSPredicate(format: "bookId == %@", bookId)
                if let obj = try self.context.fetch(fetchRequest).first {
                    self.context.delete(obj)
                    try self.saveIfNeeded(self.context)
                }
                self.callbackQueue.async { completion(.success(())) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }

    func fetch(byIDs ids: [String], completion: @escaping (Result<[String : LocalBook], Error>) -> Void) {
        guard !ids.isEmpty else {
            callbackQueue.async { completion(.success([:])) }
            return
        }
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let fetchRequest: NSFetchRequest<LocalBookEntity> = LocalBookEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "bookId IN %@", ids)
                let list = try self.context.fetch(fetchRequest)
                let dict = Dictionary(uniqueKeysWithValues: list.map { ($0.bookId ?? "", LocalBook(entity: $0)) })
                self.callbackQueue.async { completion(.success(dict)) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }

    func updateCoverData(bookId: String, data: Data?, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                let entity = try self.findRequired(by: bookId, in: self.context)
                entity.coverImageData = data
                try self.saveIfNeeded(self.context)
                self.callbackQueue.async { completion(.success(())) }
            } catch {
                self.callbackQueue.async { completion(.failure(error)) }
            }
        }
    }

}

private extension CoreDataLocalBooksRepository {
    
    func findRequired(by bookId: String, in managedObjectContext: NSManagedObjectContext) throws -> LocalBookEntity {
        let fetchRequest: NSFetchRequest<LocalBookEntity> = LocalBookEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "bookId == %@", bookId)
        guard let obj = try managedObjectContext.fetch(fetchRequest).first else {
            throw FavoritesRepositoryError.notFound
        }
        
        return obj
    }

    func findOrInsert(by bookId: String, in managedObjectContext: NSManagedObjectContext) throws -> LocalBookEntity {
        let fetchRequest: NSFetchRequest<LocalBookEntity> = LocalBookEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "bookId == %@", bookId)
        if let obj = try managedObjectContext.fetch(fetchRequest).first { return obj }
        let obj = LocalBookEntity(context: managedObjectContext)
        obj.bookId = bookId
        obj.dateAdded = obj.dateAdded ?? Date()
        
        return obj
    }

    func saveIfNeeded(_ managedObjectContext: NSManagedObjectContext) throws {
        if managedObjectContext.hasChanges { try managedObjectContext.save() }
    }

    func fill(entity: LocalBookEntity, with model: LocalBook) {
        entity.bookId = model.id
        entity.title = model.title
        entity.author = model.author
        entity.coverId = Int64(model.coverId ?? 0)
        entity.firstPublishYear = Int16(model.firstPublishYear ?? 0)
        entity.coverImageData = model.coverImageData
        entity.readingStatus = Int16(model.readingStatus.rawValue)
        entity.isFavorite = model.isFavorite
        entity.dateAdded = model.dateAdded
    }
    
}
