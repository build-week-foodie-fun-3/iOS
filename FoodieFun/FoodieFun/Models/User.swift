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


enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

enum NetworkingError: Error {
    case noData
    case noBearer
    case serverError(Error)
    case unexpectedStatusCode(Int)
    case badDecode
    case badEncode
    case noRepresentation
}

enum HeaderNames: String {
    case authorization = "Authorization"
    case contentType = "Content-Type"
}


