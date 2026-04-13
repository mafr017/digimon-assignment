//
//  NetworkClient.swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 10/04/26.
//

import Foundation
import Alamofire

protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: String, queryParameters: [URLQueryItem]?, responseType: T.Type) async -> Result<T, NetworkError>
}

final class NetworkClient: NetworkClientProtocol {
    static let shared = NetworkClient()
    
    private init() {}
    
    func request<T: Decodable>(_ endpoint: String, queryParameters: [URLQueryItem]?, responseType: T.Type) async -> Result<T, NetworkError> {
        
        guard NetworkMonitor.shared.isConnected else {
            return .failure(.noInternetConnection)
        }
        
        var components = URLComponents(string: endpoint)
        components?.queryItems = queryParameters
        
        guard let url = components?.url else {
            return .failure(.invalidURL)
        }
        
        return await withCheckedContinuation { completion in
            AF.request(url)
                .validate()
                .responseDecodable(of: T.self) { response in
                    
                    switch response.result {
                        
                    case .success(let data):
                        completion.resume(returning: .success(data))
                        
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode {
                            completion.resume(returning: .failure(.serverError(statusCode: statusCode)))
                            
                        } else if let urlError = error.underlyingError as? URLError, urlError.code == .notConnectedToInternet {
                            completion.resume(returning: .failure(.noInternetConnection))
                            
                        } else if error.isResponseSerializationError {
                            completion.resume(returning: .failure(.decodingFailed))
                            
                        } else {
                            completion.resume(returning: .failure(.unknown(error)))
                        }
                    }
                }
        }
    }
}
