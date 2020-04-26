//
//  DataFeed.swift
//  GroceryLine
//
//  Created by Andre Assadi on 4/25/20.
//  Copyright © 2020 AndreAssadiProjects. All rights reserved.
//

import Foundation


struct DataFeed: Codable {
    var id: String?
    var name: String?
    var address: String?
    var coordinates: Cor?
    var rating: Double?
    var rating_n: Double?
    var current_popularity: Int?
    var populartimes: [PTimes]
}

struct Cor: Codable {
    var lat: Double?
    var lng: Double?
}

struct PTimes: Codable {
    var name: String?
    var data: [Int8]
    
}
