//
//  ApiEndpoint.swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 10/04/26.
//

import Foundation

struct ApiEndpoint {
    static let baseURL = "https://digi-api.com/api/v1"
    static let list = baseURL + "/digimon"
    static let attribute = baseURL + "/attribute"
    static let level = baseURL + "/level"
}
