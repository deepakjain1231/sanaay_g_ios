//
//  APIService.swift
//  Tummoc
//
//  Created by Kiran Nayak on 05/01/23.
//

import Foundation

/// Primary API Service
final class APIService {
    
    /// Uses to make it Singleton instance
    public static var shared = APIService()
    
    /// Private instance
    private init() {}
    
    /// Used to make API Calls
    /// - Parameters:
    ///   - request: Request instance
    ///   - type: Expected Response type
    ///   - completion: callback with success or error
    ///   - api: Type of API
    public func execute<T: Codable>(_ req: APIRequest, responseType type: T.Type, completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let req = request(req) else {
            completion(.failure(APIError.failedToCreateRequest))
            return
        }
        URLSession.shared.dataTask(with: req) { data, response, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(APIError.unableToGetData))
                return
            }
            if let response = response as? HTTPURLResponse {
                debugPrint("APIService: Status code-> \(response.statusCode)")
                if response.statusCode == 401 {
                    completion(.failure(APIError.authorized401))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    debugPrint("APIService: result-> \(result)")
                    completion(.success(result))
                }catch {
                    debugPrint("APIService: Unable to decode \(error.localizedDescription)")
                    completion(.failure(APIError.unableToDecode))
                }
            }
        }.resume()
    }
    
    /// Construct request
    /// - Parameters:
    ///   - request: request parameters
    ///   - api: type of api
    ///   - method: method name of lamda API - Optional
    /// - Returns: URLRequest instance
    private func request(_ request: APIRequest, method: String = "") -> URLRequest? {
        guard let url = request.url else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        if request.requestBody != nil {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: request.requestBody)
        }
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.timeoutInterval = 15

        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(Utils.getAuthToken(), forHTTPHeaderField: "Authorization")
       
        debugPrint("APIService: URL-> \(url.absoluteString)")
        debugPrint("APIService: Parameters-> \(request.requestBody)")
        
        return urlRequest
    }
}


/// API Errors
enum APIError: Error {
    case failedToCreateRequest
    case authorized401
    case unableToGetData
    case unableToDecode
}
