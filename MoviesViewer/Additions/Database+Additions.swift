//
//  Database+Additions.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import Foundation
import Database
import CoreData

extension ObjectId {

    public func object() -> T? {
        DataLayer.shared.database.viewContext.find(type: T.self, objectId: objectId)
    }
}

extension Sequence {
    
    func objects<U: NSManagedObject>() -> [U] where Element == ObjectId<U> {
        objects(DataLayer.shared.database.viewContext)
    }
}

extension NSManagedObject {
    
    static func object(uri: URL, ctx: NSManagedObjectContext = DataLayer.shared.database.viewContext) -> Self? {
        if let objectId = DataLayer.shared.database.idFor(uriRepresentation: uri) {
            return ctx.find(type: self, objectId: objectId)
        }
        return nil
    }
}
