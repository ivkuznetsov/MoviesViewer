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

class ObjectsContainer<T: NSManagedObject>: Observable {
    
    private let key: String
    private let database: Database
    
    @RWAtomic private var ids: [ObjectId<T>] = []
    
    init(key: String, database: Database) {
        self.key = key
        self.database = database
        
        if let array = UserDefaults.standard.array(forKey: key) as? [String] {
            ids = array.compactMap({
                if let objectId = database.idFor(uriRepresentation: URL(string: $0)!),
                   let object = database.viewContext.find(type: T.self, objectId: objectId) {
                    return ObjectId(object)
                }
                return nil
            })
        }
    }
    
    func add(_ object: T) {
        _ids.mutate {
            let objectId = object.getObjectId
            
            if !$0.contains(objectId) {
                $0.append(objectId)
            }
            UserDefaults.standard.set($0.map { $0.objectId.uriRepresentation().absoluteString }, forKey: key)
        }
        post(nil)
    }
    
    func has(_ object: T) -> Bool {
        ids.contains(object.getObjectId)
    }
    
    func remove(_ object: T) {
        _ids.mutate {
            if let index = $0.firstIndex(of: object.getObjectId) {
                $0.remove(at: index)
            }
        }
        post(nil)
    }
    
    func objects(ctx: NSManagedObjectContext) -> [T] {
        ids.objects(ctx)
    }
    
    func objectsOnMain() -> [T] {
        ids.objects(database.viewContext)
    }
}
