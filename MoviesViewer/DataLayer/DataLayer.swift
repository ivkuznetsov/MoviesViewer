//
//  DataLayer.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import Foundation
import Database
import Network

class DataLayer {
    
    static let shared = DataLayer()
    
    let database = Database()
    let network = ServiceProvider()
    let favorites: ObjectsContainer<Movie>
    
    init() {
        Database.setup(global: database)
        favorites = ObjectsContainer(key: "favorites", database: database)
    }
}
