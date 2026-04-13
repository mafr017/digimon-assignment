//
//  DigimonQuery.Swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 11/04/26.
//

import Foundation

struct DigimonQuery {
    var name: String?
    var attribute: String?
    var level: String?
    var page: Int = 0
    var pageSize: Int = 8
}

extension DigimonQuery {

    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        if let name = name, !name.isEmpty {
            items.append(URLQueryItem(name: "name", value: name))
        }

        if let attribute = attribute {
            items.append(URLQueryItem(name: "attribute", value: attribute))
        }

        if let level = level {
            items.append(URLQueryItem(name: "level", value: level))
        }

        items.append(URLQueryItem(name: "page", value: "\(page)"))
        items.append(URLQueryItem(name: "pageSize", value: "\(pageSize)"))

        return items
    }
}
