//
//  Movie+Additions.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import Foundation
import Database
import CommonUtils
import Network

extension Movie: Fetchable {
    
    public func update(_ dict: [AnyHashable : Any]) {
        parse(dict, [(\.title, "title"),
                     (\.poster, "poster_path"),
                     (\.overview, "overview")])
        
        if let countries = dict["production_countries"] as? [[String:Any]] {
            self.countries = countries.compactMap { $0["name"] as? String }
        }
        if let companies = dict["production_companies"] as? [[String:Any]] {
            self.companies = companies.compactMap { $0["name"] as? String }
        }
        if let genres = dict["genres"] as? [[String:Any]] {
            self.genres = genres.compactMap { $0["name"] as? String }
        }
    }
    
    @MainActor static func with(uri: URL) -> Movie? {
        if let objectId = DataLayer.shared.database.idFor(uriRepresentation: uri) {
            return Movie.find(objectId: objectId)
        }
        return nil
    }
    
    static func mostPopular(offset: AnyHashable? = nil) async throws -> Page<Movie> {
        try await movies(endpoint: "4/discover/movie", parameters: ["sort_by" : "popularity.desc"], offset: offset)
    }
    
    static func search(query: String, offset: AnyHashable? = nil) async throws -> Page<Movie> {
        try await movies(endpoint: "3/search/movie", parameters: ["query" : query], offset: offset)
    }
    
    private static func movies(endpoint: String, parameters: [String : Any], offset: AnyHashable?) async throws -> Page<Movie> {
        var dict = parameters
        dict["page"] = offset
        
        let request = PageRequest<JSONPage>(.autorized(endpoint: endpoint, paramenters: dict))
        let page = try await DataLayer.shared.network.load(request)
        let items = try await DataLayer.shared.database.edit {
            Movie.parse(page.values, ctx: $0).ids
        }.objects()
        return Page(items: items, next: page.nextOffset as? AnyHashable)
    }
    
    func fullPosterURL() async throws -> URL? {
        if let poster = try await async.poster() {
            let config = try await DataLayer.shared.network.configuration()
            return URL(string: "\(config.imagesBaseUrl)w185\(poster)")
        }
        return nil
    }
    
    func updateDetails() async throws {
        let dict = try await DataLayer.shared.network.load(SerializableRequest<[String:Any]>(.autorized(endpoint: "3/movie/\(try await async.uid()!)")))
        try await DataLayer.shared.database.edit {
            Movie.findAndUpdate(serviceObject: dict, ctx: $0)?.isLoaded = true
        }
    }
    
    static var favorites: ObjectsContainer<Movie> { DataLayer.shared.favorites }
}
