//
//  RestTableViewController.swift
//  FoodieFun
//
//  Created by Dennis Rudolph on 1/6/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class RestTableViewController: UITableViewController {
    
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var segmentedSort: UISegmentedControl!
    
    var sideMenuPosition = 1
    let nameSD = NSSortDescriptor(key: "name", ascending: true)
    let recentSD = NSSortDescriptor(key: "id", ascending: false)
    let typeSD = NSSortDescriptor(key: "typeofcuisine", ascending: true)
    let ratingSD = NSSortDescriptor(key: "rating", ascending: false)
    
    var restaurantController = RestaurantController()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Restaurant> = {
    
        let fetchRequest: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        fetchRequest.sortDescriptors = [
            nameSD
        ]

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: "name", cacheName: nil)

        frc.delegate = self

        do {
            try frc.performFetch()
        } catch {
            fatalError("Error performing fetch for frc: \(error)")
        }
        return frc
    }()
    
    
    // MARK: - Methods
    
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        if segmentedSort.selectedSegmentIndex == 0 {
            do {
                fetchedResultsController.fetchRequest.sortDescriptors = [nameSD]
                try fetchedResultsController.performFetch()
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                    
                }
            } catch {
                fatalError("Error performing fetch for frc: \(error)")
            }
        } else if segmentedSort.selectedSegmentIndex == 1 {
            do {
                fetchedResultsController.fetchRequest.sortDescriptors = [recentSD]
                try fetchedResultsController.performFetch()
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                    
                }
            } catch {
                fatalError("Error performing fetch for frc: \(error)")
            }
        } else if segmentedSort.selectedSegmentIndex == 2 {
            do {
                fetchedResultsController.fetchRequest.sortDescriptors = [typeSD]
                try fetchedResultsController.performFetch()
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                    
                }
            } catch {
                fatalError("Error performing fetch for frc: \(error)")
            }
        } else if segmentedSort.selectedSegmentIndex == 3 {
            do {
                fetchedResultsController.fetchRequest.sortDescriptors = [ratingSD]
                try fetchedResultsController.performFetch()
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                    
                }
            } catch {
                fatalError("Error performing fetch for frc: \(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if restaurantController.bearer == nil {
            performSegue(withIdentifier: "LoginSegue", sender: self)
        } else {
            restaurantController.fetchAllRestaurantsFromServer( completion: { (_) in
                DispatchQueue.main.async {
                    
                        self.tableView.reloadData()
                    
                }
            })
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RestCell", for: indexPath) as? RestTableViewCell else { return UITableViewCell() }
        
        cell.restaurant = fetchedResultsController.object(at: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let restaurant = fetchedResultsController.object(at: indexPath)
            
            restaurantController.deleteRestaurant(restaurant: restaurant, context: CoreDataStack.shared.mainContext)
            
        }
    }
    
    // MARK: - Helper Methods
    
    func toggleSideMenu() {
    }

    

    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginSegue" {
            if let loginVC = segue.destination as? LoginViewController {
                loginVC.restaurantController = restaurantController
            }
            
        } else if segue.identifier == "AddRestSegue" {
            if let createVC = segue.destination as? AddRestViewController {
                createVC.restaurantController = restaurantController
            }
        } else if segue.identifier == "RestDetailSegue" {
            if let detailVC = segue.destination as? DetailRestViewController,
                let indexPath = tableView.indexPathForSelectedRow {
                detailVC.restaurant = fetchedResultsController.object(at: indexPath)
                detailVC.restaurantController = restaurantController
            }
        } else if segue.identifier == "ProfileSegue" {
            if let profileVC = segue.destination as? ProfileViewController {
                profileVC.user = restaurantController.loggedInUser
            }
        }
    }
}

extension RestTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
            
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
        @unknown default:
            fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default:
            return
        }
        
    }
}
