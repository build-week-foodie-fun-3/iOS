//
//  ReviewRepresentation.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct ReviewRepresentation: Codable {
    let id: Int32?
    let menuItem: String
    let price: String?
    let itemRating: Int32?
    let photoUrl: String
    let itemReview: String
    let typeOfCuisine: String
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case menuItem = "menuitem"
        case price
        case itemRating = "itemrating"
        case photoUrl = "photourl"
        case itemReview = "itemreview"
        case typeOfCuisine = "typeofcuisine"
        case name
    }
}

struct ReviewPostRepresentation: Codable {
    let id: Int32?
    let menuItem: String
    let price: String?
    let itemRating: Int32?
    let photoUrl: String
    let itemReview: String
    let typeOfCuisine: String
    let restaurantId: Int32
    
    private enum CodingKeys: String, CodingKey {
        case id
        case menuItem = "menuitem"
        case price
        case itemRating = "itemrating"
        case photoUrl = "photourl"
        case itemReview = "itemreview"
        case typeOfCuisine = "typeofcuisine"
        case restaurantId = "restaurant_id"
    }
}
