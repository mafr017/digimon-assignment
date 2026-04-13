//
//  NetworkError.swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 10/04/26.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case noInternetConnection
    case invalidURL
    case decodingFailed
    case serverError(statusCode: Int)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No internet connection."
        case .invalidURL:
            return "URL not valid."
        case .decodingFailed:
            return "Failed to decode data from server."
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
