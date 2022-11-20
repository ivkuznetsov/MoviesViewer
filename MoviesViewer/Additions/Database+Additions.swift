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
