//
//  Restaurant+Convenience.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Restaurant {
    var restaurantRepresentation: RestaurantRepresentation? {
        
        guard let name = name else { return nil}
       
        let restaurant = RestaurantRepresentation(id: id, name: name, location: location, hours: hours ?? "", photoUrl: photourl ?? "", rating: rating ?? "", typeOfCuisine: typeofcuisine ?? "", userId: userId)
        return restaurant
    }
    
    @discardableResult convenience init(id: Int32, name: String, location: String, hours: String?, photoUrl: String?, rating: String?, typeOfCuisine: String?, userId: Int32, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = id
        self.name = name
        self.location = location
        self.hours = hours
        self.photourl = photoUrl
        self.rating = rating
        self.typeofcuisine = typeOfCuisine
        self.userId = userId
    }
    
    @discardableResult convenience init?(restaurantRep: RestaurantRepresentation, context: NSManagedObjectContext) {
        
        self.init(id: restaurantRep.id ?? -1, name: restaurantRep.name, location: restaurantRep.location ?? "", hours: restaurantRep.hours, photoUrl: restaurantRep.photoUrl, rating: restaurantRep.rating, typeOfCuisine: restaurantRep.typeOfCuisine, userId: restaurantRep.userId, context: context)
    }
}
