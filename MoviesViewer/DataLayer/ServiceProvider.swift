//
//  ServiceProvider.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 20/11/2022.
//

import Foundation
import Network
import CommonUtils

extension RequestParameters {
    
    static func autorized(endpoint: String, paramenters: [String : Any]? = nil) -> RequestParameters {
        var params = paramenters ?? [:]
        params["api_key"] = "40dd6d254bb15a70311b60b8666a04ac"
        return .init(endpoint: endpoint, paramenters: params)
    }
}

class ServiceProvider: NetworkProvider {
    
    struct Configuration: Codable {
        
        let imagesBaseUrl: String
        
        init(dict: [String : Any]) throws {
            if let images = dict["images"] as? [String : Any],
               let imagesBaseUrl = images["base_url"] as? String {
                self.imagesBaseUrl = imagesBaseUrl
                return
            }
            throw RunError.custom("Cannot parse response")
        }
    }
    
    init() {
        super.init(baseURL: URL(string: "https://api.themoviedb.org/")!,
                   validateBody: { _, body in
            if let success = body?["success"] as? Bool, success == false {
                throw RunError.custom(body?["status_message"] as? String ?? "Request Failed")
            }
        })
    }
    
    @RWAtomic var configuration: Configuration?
    
    func loadConfig()->Work<Configuration> {
        _configuration.locking {
            if let configuration = $0 {
                return .value(configuration)
            }
            return load(SerializableRequest(.autorized(endpoint: "3/configuration"))).convert {
                try Configuration.init(dict: $0)
            }.success {
                self.configuration = $0
            }.singleton("configuration")
        }
    }
}
