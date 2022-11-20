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

struct Page: ResponsePage {
    
    var values: [[String : Any]]
    var nextOffset: Any?
    
    init?(dict: [String : Any]) {
        values = dict["results"] as? [[String : Any]] ?? []
        let totalPages = dict["total_pages"] as? Int64 ?? 0
        let currentPage = dict["page"] as? Int64 ?? 0
        nextOffset = currentPage < totalPages - 1 ? (currentPage + 1) : nil
    }
}

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
    
    static func mostPopular(offset: Any? = nil) -> Work<(ids: [ObjectId<Movie>], next: Any?)> {
        movies(endpoint: "4/discover/movie", parameters: ["sort_by" : "popularity.desc"], offset: offset)
    }
    
    static func search(query: String, offset: Any? = nil) -> Work<(ids: [ObjectId<Movie>], next: Any?)> {
        movies(endpoint: "4/search/movie", parameters: ["query" : query], offset: offset)
    }
    
    private static func movies(endpoint: String, parameters: [String : Any], offset: Any?) -> Work<(ids: [ObjectId<Movie>], next: Any?)> {
        var dict = parameters
        dict["page"] = offset
        
        let request = PageRequest<Page>(.autorized(endpoint: endpoint, paramenters: dict))
        return DataLayer.shared.network.load(request).chain { page in
            DataLayer.shared.database.editOp { ctx in
                (ctx.parse(Movie.self, array: page.values).ids, page.nextOffset)
            }
        }
    }
    
    func fullPosterURL() -> Work<URL?> {
        if let poster = poster {
            return DataLayer.shared.network.loadConfig().convert {
                URL(string: "\($0.imagesBaseUrl)w185\(poster)")
            }
        } else {
            return .value(nil)
        }
    }
    
    func updateDetails() -> VoidWork {
        DataLayer.shared.network.load(SerializableRequest<[String:Any]>(.autorized(endpoint: "3/movie/\(uid!)"))).then { dict in
            DataLayer.shared.database.editOp { ctx in
                let movie = ctx.findAndUpdate(Movie.self, serviceObject: dict)
                movie?.isLoaded = true
            }
        }
    }
    
    static var favorites: ObjectsContainer<Movie> { DataLayer.shared.favorites }
}
