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
    
    var restaurantController = RestaurantController()
    
//    lazy var fetchedResultsController: NSFetchedResultsController<BucketList> = {
//
//        let fetchRequest: NSFetchRequest<BucketList> = BucketList.fetchRequest()
//        fetchRequest.sortDescriptors = [
//            NSSortDescriptor(key: "name", ascending: true)
//        ]
//
//        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: "name", cacheName: nil)
//
//        frc.delegate = self
//
//        do {
//            try frc.performFetch()
//        } catch {
//            fatalError("Error performing fetch for frc: \(error)")
//        }
//        return frc
//    }()
    
    
    // MARK: - Methods


    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if restaurantController.bearer == nil {
            performSegue(withIdentifier: "LoginSegue", sender: self)
            
        } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginSegue" {
            if let loginVC = segue.destination as? LoginViewController {
                loginVC.restaurantController = restaurantController
            }
            
//        } else if segue.identifier == "CreateBucketListSegue" {
//            if let createBLVC = segue.destination as? CreateBucketListViewController {
//                createBLVC.bucketListController = bucketListController
//            }
//        } else if segue.identifier == "BLDetailViewSegue" {
//            if let bucketListItemVC = segue.destination as? BucketListItemViewController,
//                let indexPath = tableView.indexPathForSelectedRow {
//                bucketListItemVC.bucketList = fetchedResultsController.object(at: indexPath)
//                bucketListItemVC.bucketListController = bucketListController
//            }
//        }
        }
    }
}
