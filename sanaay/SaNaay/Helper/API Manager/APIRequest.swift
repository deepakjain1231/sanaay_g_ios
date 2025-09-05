//
//  APIRequest.swift
//  Tummoc
//
//  Created by Kiran Nayak on 05/01/23.
//

import Foundation

/// Object used as a request body
final class APIRequest {
    
    /// Target Base URL
    private let baseURL: String
    
    /// Target Endpoint
    private let endpoint: APIEndpoints
    
    /// Collection of path parameters
    private let pathComponents: [String]
    
    /// Collection of query parameter
    private let queryComponent: [URLQueryItem]
    
    /// Request Body
    public let requestBody: [String: Any]?
    
    /// Construct url with path parameters and query parameters
    private var urlString: String {
        var str = baseURL
        str += endpoint.rawValue
        
        if !pathComponents.isEmpty {
            pathComponents.forEach {
                str += "/\($0)"
            }
        }
        
        if !queryComponent.isEmpty {
            str += "?"
            let argumentString = queryComponent.compactMap({
                guard let value = $0.value else {
                    return nil
                }
                return "\($0.name)=\(value)"
            }).joined(separator: "&")
            str += argumentString
        }
            
        return str
    }
    
    /// Target HTTP Method
    public let httpMethod: HTTPMethodType
    
    /// Construct API URLS
    public var url: URL? {
        return URL(string: urlString)
    }
    
    /// Construct request
    /// - Parameters:
    ///   - baseURL: Target Base URL
    ///   - endpoint: Target Endpoint
    ///   - pathComponents: collection of path path parameter
    ///   - queryComponent: collection of query parameter
    ///   - httpMethod: Target HTTP Method
    ///   - requestBody: Target HTTP Request
    init(
        baseURL: String, endpoint: APIEndpoints,
        pathComponents: [String] = [],
        queryComponent: [URLQueryItem] = [],
        httpMethod: HTTPMethodType,
        requestBody: [String: Any]?
    ) {
        self.baseURL = baseURL
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryComponent = queryComponent
        self.httpMethod = httpMethod
        self.requestBody = requestBody
    }
    
}

enum HTTPMethodType: String {
    case GET = "GET"
    case POST = "POST"
}
