//
//  DigimonFilter.swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 11/04/26.
//

import Foundation

struct DigimonFilter: Decodable {
    let content: FilterList
    let pageable: Pagination
}

struct FilterList: Decodable {
    let name: String?
    let description: String?
    let fields: [BaseResponse]?
}

struct BaseResponse: Decodable {
    let id: Int?
    let name: String?
}
