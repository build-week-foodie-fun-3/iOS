//
//  DetailRestViewController.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class DetailRestViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var restImageView: UIImageView!
    
    var restaurant: Restaurant?
    var restaurantController: RestaurantController?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Review> = {

          let fetchRequest: NSFetchRequest<Review> = Review.fetchRequest()
          fetchRequest.sortDescriptors = [
              NSSortDescriptor(key: "menuitem", ascending: true)
          ]

          let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: "menuitem", cacheName: nil)

          frc.delegate = self

          do {
              try frc.performFetch()
          } catch {
              fatalError("Error performing fetch for frc: \(error)")
          }
          return frc
      }()
    
    let demoImages: [String] = [
        "https://images.pexels.com/photos/6267/menu-restaurant-vintage-table.jpg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260",
        "https://images.pexels.com/photos/67468/pexels-photo-67468.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260",
        "https://images.pexels.com/photos/260922/pexels-photo-260922.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260"
    
    ]
    
    var demoIndex = Int.random(in: 0...2)

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        self.reviewTableView.dataSource = self
        self.reviewTableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard restaurant != nil else { return }
        do {
            try self.fetchedResultsController.performFetch()
            self.reviewTableView.reloadData()
    } catch {
            print("error with the thing")
        }
    }
    
    
    func updateViews() {
        nameLabel.text = restaurant?.name
        locationLabel.text = restaurant?.location
        hoursLabel.text = restaurant?.hours
        ratingLabel.text = restaurant?.rating
        typeLabel.text = restaurant?.typeofcuisine
        if restImageView.image == nil, let imageURL = URL(string: demoImages[demoIndex]) {
            
            do {
                let image = try UIImage(withContentsOfURL: imageURL)
                restImageView.image = image
            } catch {
                print("Error converting image URL: \(error)")
            }
        }
        
        demoIndex = Int.random(in: 0...2)
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateReviewSegue" {
            if let addVC = segue.destination as? AddReviewViewController {
                addVC.restaurantController = restaurantController
                addVC.restaurant = restaurant
            }
        } else if segue.identifier == "ReviewDetailSegue" {
            if let detailVC = segue.destination as? ReviewDetailViewController,
                let indexPath = reviewTableView.indexPathForSelectedRow {
                detailVC.review = fetchedResultsController.object(at: indexPath)
                detailVC.restaurantController = restaurantController
            }
        } else if segue.identifier == "EditRestSegue" {
            if let detailVC = segue.destination as? AddRestViewController {
                detailVC.restaurant = self.restaurant
                detailVC.restaurantController = restaurantController
            }
        }
    }
}

extension DetailRestViewController: UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewTableViewCell else { return UITableViewCell() }
        
        cell.review = fetchedResultsController.object(at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let review = fetchedResultsController.object(at: indexPath)
            
            restaurantController?.deleteReview(review: review, context: CoreDataStack.shared.mainContext)
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reviewTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reviewTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            reviewTableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .delete:
            guard let indexPath = indexPath else { return }
            reviewTableView.deleteRows(at: [indexPath], with: .automatic)
            
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            reviewTableView.moveRow(at: indexPath, to: newIndexPath)
            
        case .update:
            guard let indexPath = indexPath else { return }
            reviewTableView.reloadRows(at: [indexPath], with: .automatic)
            
        @unknown default:
            fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            reviewTableView.insertSections(indexSet, with: .automatic)
        case .delete:
            reviewTableView.deleteSections(indexSet, with: .automatic)
        default:
            return
        }
        
    }
    
}

extension UIImage {
    
    convenience init?(withContentsOfURL url: URL) throws {
        let imageData = try Data(contentsOf: url)
        
        self.init(data: imageData)
    }
    
}
