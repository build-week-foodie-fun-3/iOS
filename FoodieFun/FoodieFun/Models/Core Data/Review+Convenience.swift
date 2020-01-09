//
//  Review+Convenience.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Review {
    
    var reviewRepresentation: ReviewRepresentation? {
        
        guard let menuItem = menuitem else { return nil}
       
        let review = ReviewRepresentation(id: id, menuItem: menuItem, price: price, itemRating: itemrating, photoUrl: photourl ?? "", itemReview: itemreview ?? "", typeOfCuisine: typeofcuisine ?? "", name: "")
        return review
    }
    
    @discardableResult convenience init(id: Int32, menuItem: String, price: String, itemRating: Int32, photoUrl: String?, itemReview: String?, typeOfCuisine: String?, restaurantId: Int32, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = id
        self.menuitem = menuItem
        self.price = price
        self.itemrating = itemRating
        self.photourl = photoUrl
        self.itemreview = itemReview
        self.typeofcuisine = typeOfCuisine
        self.restaurant_id = restaurantId
    }
    
    @discardableResult convenience init?(reviewRep: ReviewRepresentation, restaurantId: Int32, context: NSManagedObjectContext) {
        
        self.init(id: reviewRep.id ?? -1, menuItem: reviewRep.menuItem, price: reviewRep.price ?? "", itemRating: reviewRep.itemRating ?? 0, photoUrl: reviewRep.photoUrl, itemReview: reviewRep.itemReview, typeOfCuisine: reviewRep.typeOfCuisine, restaurantId: restaurantId, context: context)
    }
}
