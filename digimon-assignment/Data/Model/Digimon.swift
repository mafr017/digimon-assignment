//
//  Digimon.swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 11/04/26.
//

import Foundation

struct Digimon: Codable {
    let id: Int?
    let name: String?
    let images: [Image]?
    let levels: [Level]?
    let types: [TypeElement]?
    let attributes: [Attribute]?
    let fields: [Field]?
    let descriptions: [Description]?
    let skills: [Skill]?
}

struct Attribute: Codable {
    let id: Int?
    let attribute: String?
}

struct Description: Codable {
    let origin, language, description: String?
}

struct Field: Codable {
    let id: Int?
    let field: String?
    let image: String?
}

struct Image: Codable {
    let href: String?
    let transparent: Bool?
}

struct Level: Codable {
    let id: Int?
    let level: String?
}

struct Skill: Codable {
    let id: Int?
    let skill, translation, description: String?
}

struct TypeElement: Codable {
    let id: Int?
    let type: String?
}
