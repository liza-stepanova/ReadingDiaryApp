import CoreData

protocol CoreDataStackProtocol {
    
    var viewContext: NSManagedObjectContext { get }
    func newBackgroundContext() -> NSManagedObjectContext
    
}

final class CoreDataStack: CoreDataStackProtocol {
    
    let container: NSPersistentContainer

    init(name: String = "ReadingDiary") {
        container = NSPersistentContainer(name: name)

        if let desc = container.persistentStoreDescriptions.first {
            desc.shouldMigrateStoreAutomatically = true
            desc.shouldInferMappingModelAutomatically = true
        }
        
//        if let url = container.persistentStoreDescriptions.first?.url {
//            print("Core Data store URL: \(url.path)")
//        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data store failed to load: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
        
        return context
    }
    
}
