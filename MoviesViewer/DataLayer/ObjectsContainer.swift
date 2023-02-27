//
//  ObjectsContainer.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 20/11/2022.
//

import Foundation
import CommonUtils
import Database
import CoreData

@MainActor
class ObjectsContainer<T: NSManagedObject>: ObservableObject {
    
    private let key: String
    private let database: Database
    
    @Published private var ids: [ObjectId<T>] = []
    
    nonisolated init(key: String, database: Database) {
        self.key = key
        self.database = database
        
        Task { @MainActor in setup() }
    }
    
    private func setup() {
        if let array = UserDefaults.standard.array(forKey: key) as? [String] {
            ids = array.compactMap({
                if let objectId = database.idFor(uriRepresentation: URL(string: $0)!),
                   let object = T.find(objectId: objectId) {
                    return ObjectId(object)
                }
                return nil
            })
        }
        
        $ids.sink { [unowned self] in
            UserDefaults.standard.set($0.map { $0.objectId.uriRepresentation().absoluteString }, forKey: key)
        }.retained(by: self)
    }
    
    func add(_ object: T) {
        let objectId = object.getObjectId
            
        if !ids.contains(objectId) {
            ids.append(objectId)
        }
    }
    
    func has(_ object: T) -> Bool {
        ids.contains(object.getObjectId)
    }
    
    func remove(_ object: T) {
        if let index = ids.firstIndex(of: object.getObjectId) {
            ids.remove(at: index)
        }
    }
    
    func objects(ctx: NSManagedObjectContext) -> [T] {
        ids.objects(ctx)
    }
    
    func objectsOnMain() -> [T] {
        ids.objects(database.viewContext)
    }
}
