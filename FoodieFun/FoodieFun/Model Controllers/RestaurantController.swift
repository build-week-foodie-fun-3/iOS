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
    
    
    // MARK: - Restaurant Core Data CRUD Methods
    
    func createRestaurant(id: Int32, name: String, location: String, hours: String, photoUrl: String, rating: String, typeOfCuisine: String, context: NSManagedObjectContext, completion: @escaping () -> Void) {
        
        guard let loggedInUser = loggedInUser, let userId = loggedInUser.id else { return }
        
        let restaurantRep = RestaurantRepresentation(id: nil, name: name, location: location, hours: hours, photoUrl: photoUrl, rating: rating, typeOfCuisine: typeOfCuisine, userId: userId)
        
        createRestaurantToServer(restaurantRep: restaurantRep) { (result) in
            do {
                _ = try result.get()

                self.fetchAllRestaurantsFromServer()
                completion()
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
                    restaurant.user_id = representation.userId ?? -1
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
    
    // MARK: - Restaurant Server CRUD Methods
    
    func createRestaurantToServer(restaurantRep: RestaurantRepresentation, completion: @escaping (Result<RestaurantRepresentation, NetworkingError>) -> Void) {
        
        guard let bearer = bearer else {
            completion(.failure(.noBearer))
            return
        }
        
        let requestURL = baseURL.appendingPathComponent("/api/auth/restaurant")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
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
    
    
    // MARK: - Review Core Data CRUD Methods
    
    func createReview(restaurant: Restaurant, restaurantName: String, menuItem: String, price: String, itemRating: Int32, photoUrl: String, itemReview: String, typeOfCuisine: String, context: NSManagedObjectContext, completion: @escaping () -> Void) {
                
        let reviewPostRep = ReviewPostRepresentation(id: nil, menuItem: menuItem, price: price, itemRating: itemRating, photoUrl: photoUrl, itemReview: itemReview, typeOfCuisine: typeOfCuisine, restaurantId: restaurant.id)
        
        createReviewToServer(reviewPostRep: reviewPostRep) { (result) in
            do {
                _ = try result.get()

                self.fetchAllReviewsForRestaurantFromServer(restaurant: restaurant)
                completion()
            } catch {
                print("Error creating a review to server: \(error)")
            }
        }
    }
    
    func updateReview(review: Review, restaurantName: String, menuItem: String, price: String, itemRating: Int32, photoUrl: String, itemReview: String, typeOfCuisine: String, context: NSManagedObjectContext) {
        
        updateReviewToServer(review: review) { (result) in
            do {
                _ = try result.get()
                CoreDataStack.shared.save(context: context)
            } catch {
                print("Error updating the review to server: \(error)")
            }
        }
    }
    
    func deleteReview(review: Review, context: NSManagedObjectContext) {
        context.performAndWait {
            deleteReviewFromServer(review: review) { (result) in
                do {
                    let review = try result.get()
                    context.delete(review)
                    CoreDataStack.shared.save(context: context)
                } catch {
                    print("Error deleting review from server: \(error)")
                }
            }
        }
    }
    
    func updateReviewCDfromServerFetch(with representations: [ReviewRepresentation], restID: Int32) {
        
        let identifiersToFetch = representations.map({ $0.id })
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var reviewsToCreate = representationsByID
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            
            do {
                let fetchRequest: NSFetchRequest<Review> = Review.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id IN %@", identifiersToFetch)
                
                let existingReviews = try context.fetch(fetchRequest)
                
                for review in existingReviews {
                    
                    let id = review.id
                    guard let representation = representationsByID[id] else { continue }
                    
                    guard let repId = representation.id else { return }
                    review.id = repId
                    review.menuitem = representation.menuItem
                    review.typeofcuisine = representation.typeOfCuisine
                    review.photourl = representation.photoUrl
                    review.price = representation.price
                    review.itemrating = representation.itemRating ?? 0
                    review.itemreview = representation.itemReview

                    reviewsToCreate.removeValue(forKey: id)
                }

                for representation in reviewsToCreate.values {
                    // need to find a way to pass in
                   Review(reviewRep: representation, restaurantId: restID, context: context)
                }
                CoreDataStack.shared.save(context: context)
            } catch {
                print("Error fetching reviews from persistent store: \(error)")
            }
        }
    }
    
    // MARK: - Review Server CRUD Methods
    
    func createReviewToServer(reviewPostRep: ReviewPostRepresentation, completion: @escaping (Result<ReviewPostRepresentation, NetworkingError>) -> Void) {
        
        guard let bearer = bearer else {
            completion(.failure(.noBearer))
            return
        }
        
        let requestURL = baseURL.appendingPathComponent("/api/auth/review")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("\(bearer.token)", forHTTPHeaderField: HeaderNames.authorization.rawValue)
        request.setValue("application/json", forHTTPHeaderField: HeaderNames.contentType.rawValue)
        
        do {
            request.httpBody = try JSONEncoder().encode(reviewPostRep)
        } catch {
            print("Error encoding review representation: \(error)")
            completion(.failure(.badEncode))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            
            if let error = error {
                print("Error POSTing review: \(error)")
                completion(.failure(.serverError(error)))
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 201 {
                print("Unexpected status code: \(response.statusCode)")
                completion(.failure(.unexpectedStatusCode(response.statusCode)))
                return
            }
            
            completion(.success(reviewPostRep))
        }.resume()
    }
    
    func updateReviewToServer(review: Review, completion: @escaping (Result<Review,NetworkingError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noBearer))
            return
        }
        
        guard let reviewRep = review.reviewRepresentation else {
            completion(.failure(.noRepresentation))
            return
        }
        
        let requestURL = baseURL.appendingPathComponent("/api/auth/review/").appendingPathComponent(String(review.id))
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        request.setValue("\(bearer.token)", forHTTPHeaderField: HeaderNames.authorization.rawValue)
        request.setValue("application/json", forHTTPHeaderField: HeaderNames.contentType.rawValue)
        
        do {
            request.httpBody = try JSONEncoder().encode(reviewRep)
        } catch {
            print("Error encoding review representation: \(error)")
            completion(.failure(.badEncode))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            
            if let error = error {
                print("Error PUTing review: \(error)")
                completion(.failure(.serverError(error)))
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                print("Unexpected status code: \(response.statusCode)")
                completion(.failure(.unexpectedStatusCode(response.statusCode)))
                return
            }
            
            completion(.success(review))
        }.resume()
    }
    
    func deleteReviewFromServer(review: Review, completion: @escaping (Result<Review,NetworkingError>) -> Void) {
        
        let requestURL = baseURL.appendingPathComponent("/api/auth/review/").appendingPathComponent(String(review.id))
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            
            if let error = error {
                print("Error deleting review \(review.id) from server: \(error)")
                completion(.failure(.serverError(error)))
                return
            }
            completion(.success(review))
        }.resume()
    }
    
    func fetchAllReviewsForRestaurantFromServer(restaurant: Restaurant, completion: @escaping (Error?) -> Void = { _ in }) {
        
        let restaurantId = restaurant.id
        
        let requestURL = baseURL.appendingPathComponent("/api/auth/\(String(restaurantId))/reviews")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Error fetching reviews: \(error)")
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
                print("No data returned from review fetch")
                completion(error)
                return
            }
            
            do {
                let reviews = try JSONDecoder().decode([ReviewRepresentation].self, from: data)
                self.updateReviewCDfromServerFetch(with: reviews, restID: restaurantId)
            } catch {
                print("Error decoding review Representations: \(error)")
                completion(error)
            }
            completion(nil)
        }.resume()
    }

}

