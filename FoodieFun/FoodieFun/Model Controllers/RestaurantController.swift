//
//  RestaurantController.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class RestaurantController {
    
    var bearer: Bearer?
    
    var loggedInUser: User?
    
    let baseURL = URL(string: "https://foodiefun3.herokuapp.com")!
    
    
    // MARK: - User methods
    
    
    func signUp(with user: User, completion: @escaping (Error?) -> ()) {
        let signUpURL = baseURL.appendingPathComponent("/api/register")
        
        var request = URLRequest(url: signUpURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 201 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func login(with user: User, completion: @escaping (Error?) -> ()) {
        let signInURL = baseURL.appendingPathComponent("/api/login")
        
        var request = URLRequest(url: signInURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)
                self.loggedInUser = user
                self.loggedInUser?.id = self.bearer?.id
            } catch {
                print("Error decoding bearer object: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    
    // MARK: - Core Data CRUD Methods
    
    func createRestaurant(id: Int32, name: String, location: String, hours: String, photoUrl: String, rating: String, typeOfCuisine: String, context: NSManagedObjectContext) {
        
        guard let loggedInUser = loggedInUser, let userId = loggedInUser.id else { return }
        
        let restaurantRep = RestaurantRepresentation(id: id, name: name, location: location, hours: hours, photoUrl: photoUrl, rating: rating, typeOfCuisine: typeOfCuisine, userId: userId)
        
        createRestaurantToServer(restaurantRep: restaurantRep) { (result) in
            do {
                _ = try result.get()

                self.fetchAllRestaurantsFromServer()
            } catch {
                print("Error creating a restaurant to server: \(error)")
            }
        }
    }
    
    func updateRestaurant(restaurant: Restaurant, id: Int32, name: String, location: String, hours: String, photoUrl: String, rating: String, typeOfCuisine: String, context: NSManagedObjectContext) {
        
        updateRestaurantToServer(restaurant: restaurant) { (result) in
            do {
                _ = try result.get()
                CoreDataStack.shared.save(context: context)
            } catch {
                print("Error updating the restaurant to server: \(error)")
            }
        }
    }
    
    func deleteRestaurant(restaurant: Restaurant, context: NSManagedObjectContext) {
        context.performAndWait {
            deleteRestaurantFromServer(restaurant: restaurant) { (result) in
                do {
                    let restaurant = try result.get()
                    context.delete(restaurant)
                    CoreDataStack.shared.save(context: context)
                } catch {
                    print("Error deleting restaurant from server: \(error)")
                }
            }
        }
    }
    
    func updateCDfromServerFetch(with representations: [RestaurantRepresentation]) {
                
        let identifiersToFetch = representations.map({ $0.id })
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var restaurantsToCreate = representationsByID
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            
            do {
                let fetchRequest: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id IN %@", identifiersToFetch)
                
                let existingRestaurants = try context.fetch(fetchRequest)
                
                for restaurant in existingRestaurants {
                    
                    let id = restaurant.id
                    guard let representation = representationsByID[id] else { continue }
                    
                    guard let repId = representation.id else { return }
                    restaurant.id = repId
                    restaurant.name = representation.name
                    restaurant.hours = representation.hours
                    restaurant.typeofcuisine = representation.typeOfCuisine
                    restaurant.rating = representation.rating
                    restaurant.userId = representation.userId
                    restaurant.location = representation.location
                    restaurant.photourl = representation.photoUrl
                
                    restaurantsToCreate.removeValue(forKey: id)
                }
                
                for representation in restaurantsToCreate.values {
                   Restaurant(restaurantRep: representation, context: context)
                }
                CoreDataStack.shared.save(context: context)
            } catch {
                print("Error fetching restaurants from persistent store: \(error)")
            }
        }
    }
    
    // MARK: - Server CRUD Methods
    
    func createRestaurantToServer(restaurantRep: RestaurantRepresentation, completion: @escaping (Result<RestaurantRepresentation, NetworkingError>) -> Void) {
        
        guard let bearer = bearer else {
            completion(.failure(.noBearer))
            return
        }
        
        let requestURL = baseURL.appendingPathComponent("/api/auth/restaurant")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("\(bearer.token)", forHTTPHeaderField: HeaderNames.authorization.rawValue)
        request.setValue("application/json", forHTTPHeaderField: HeaderNames.contentType.rawValue)
        
        do {
            request.httpBody = try JSONEncoder().encode(restaurantRep)
        } catch {
            print("Error encoding restaurant representation: \(error)")
            completion(.failure(.badEncode))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            
            if let error = error {
                print("Error POSTing restaurant: \(error)")
                completion(.failure(.serverError(error)))
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 201 {
                print("Unexpected status code: \(response.statusCode)")
                completion(.failure(.unexpectedStatusCode(response.statusCode)))
                return
            }
            
            completion(.success(restaurantRep))
        }.resume()
    }
  
    func updateRestaurantToServer(restaurant: Restaurant, completion: @escaping (Result<Restaurant,NetworkingError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noBearer))
            return
        }
        
        guard let restaurantRep = restaurant.restaurantRepresentation else {
            completion(.failure(.noRepresentation))
            return
        }
        
        let requestURL = baseURL.appendingPathComponent("/api/auth/restaurant/").appendingPathComponent(String(restaurant.id))
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        request.setValue("\(bearer.token)", forHTTPHeaderField: HeaderNames.authorization.rawValue)
        request.setValue("application/json", forHTTPHeaderField: HeaderNames.contentType.rawValue)
        
        do {
            request.httpBody = try JSONEncoder().encode(restaurantRep)
        } catch {
            print("Error encoding restaurant representation: \(error)")
            completion(.failure(.badEncode))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            
            if let error = error {
                print("Error PUTing restaurant: \(error)")
                completion(.failure(.serverError(error)))
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                print("Unexpected status code: \(response.statusCode)")
                completion(.failure(.unexpectedStatusCode(response.statusCode)))
                return
            }
            
            completion(.success(restaurant))
        }.resume()
    }
 
    func deleteRestaurantFromServer(restaurant: Restaurant, completion: @escaping (Result<Restaurant,NetworkingError>) -> Void) {
        
        let requestURL = baseURL.appendingPathComponent("/api/auth/restaurant/").appendingPathComponent(String(restaurant.id))
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            
            if let error = error {
                print("Error deleting restaurant \(restaurant.id) from server: \(error)")
                completion(.failure(.serverError(error)))
                return
            }
            completion(.success(restaurant))
        }.resume()
    }
    
    func fetchAllRestaurantsFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let userId = loggedInUser?.id else { return }
        
        let requestURL = baseURL.appendingPathComponent("/api/auth/restaurant/").appendingPathComponent(String(userId))
        
        let request = URLRequest(url: requestURL)
    
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Error fetching all restaurants: \(error)")
                completion(error)
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                print("Unexpected status code: \(response.statusCode)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("No data returned from restaurant fetch")
                completion(error)
                return
            }
            
            do {
                let restaurants = try JSONDecoder().decode([RestaurantRepresentation].self, from: data)
                self.updateCDfromServerFetch(with: restaurants)
            } catch {
                print("Error decoding restaurant Representations: \(error)")
                completion(error)
            }
            completion(nil)
        }.resume()
    }
}
