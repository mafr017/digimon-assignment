//
//  Pagination.swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 11/04/26.
//

import Foundation

struct Pagination: Decodable {
    let currentPage, elementsOnPage, totalElements, totalPages: Int
}
