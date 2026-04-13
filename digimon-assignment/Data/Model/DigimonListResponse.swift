//
//  DigimonListResponse.swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 11/04/26.
//

import Foundation

struct DigimonListResponse: Decodable {
    let content: [DigimonList]?
    let pageable: Pagination
}

struct DigimonList: Decodable {
    let id: Int?
    let name: String?
    let href: String?
    let image: String?
}
