//
//  User.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct User: Codable {
    let username: String
    var password: String
    var location: String?
    var email: String?
    var id: Int32?
    
    enum CodingKeys: String, CodingKey {
        case username
        case password
        case email
        case location
        case id
    }
}
