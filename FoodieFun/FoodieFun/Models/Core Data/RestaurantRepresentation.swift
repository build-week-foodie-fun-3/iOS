//
//  RestaurantRepresentation.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct RestaurantRepresentation: Codable {
    let id: Int32?
    let name: String
    let location: String?
    let hours: String
    let photoUrl: String
    let rating: String
    let typeOfCuisine: String
    let userId: Int32
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case hours
        case rating
        case photoUrl = "photourl"
        case typeOfCuisine = "typeofcuisine"
        case userId = "user_id"
    }
}
