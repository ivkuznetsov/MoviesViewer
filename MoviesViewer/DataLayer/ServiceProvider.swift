//
//  ServiceProvider.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 20/11/2022.
//

import Foundation
import Network
import CommonUtils

struct Page<T: Hashable> {
    let items: [T]
    let next: AnyHashable?
}

struct JSONPage: ResponsePage {
    var values: [[String : Any]]
    var nextOffset: Any?
    
    init?(dict: [String : Any]) {
        values = dict["results"] as? [[String : Any]] ?? []
        let totalPages = dict["total_pages"] as? Int64 ?? 0
        let currentPage = dict["page"] as? Int64 ?? 0
        nextOffset = currentPage < totalPages - 1 ? (currentPage + 1) : nil
    }
}

extension RequestParameters {
    
    static func autorized(endpoint: String, paramenters: [String : Any]? = nil) -> RequestParameters {
        var params = paramenters ?? [:]
        params["api_key"] = "40dd6d254bb15a70311b60b8666a04ac"
        return .init(endpoint: endpoint, parameters: params)
    }
}

class ServiceProvider: NetworkProvider {
    
    struct Configuration {
        let imagesBaseUrl: String
        
        init(dict: [String : Any]) throws {
            if let images = dict["images"] as? [String : Any],
               let imagesBaseUrl = images["base_url"] as? String {
                self.imagesBaseUrl = imagesBaseUrl
            } else {
                throw RunError.custom("Cannot parse response")
            }
        }
    }
    
    init() {
        super.init(baseURL: URL(string: "https://api.themoviedb.org/")!,
                   validateBody: { _, body in
            if let success = body?["success"] as? Bool, success == false {
                throw RunError.custom(body?["status_message"] as? String ?? "Request Failed")
            }
        }, logging: false)
    }
    
    private var currentConfiguraiton: Configuration?
    
    func configuration() async throws -> Configuration {
        try await SingletonTasks.run(key: "config") {
            if let configuraiton = self.currentConfiguraiton {
                return configuraiton
            }
            let dict = try await self.load(SerializableRequest<[String:Any]>(.autorized(endpoint: "3/configuration")))
            let result = try Configuration(dict: dict)
            self.currentConfiguraiton = result
            return result
        }
    }
}
