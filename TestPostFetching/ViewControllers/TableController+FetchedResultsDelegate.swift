//
//  UITableViewController+Extension.swift
//  TestPostFetching
//
//  Created by user167484 on 5/4/20.
//  Copyright © 2020 Allen Savio. All rights reserved.
//

import UIKit
import CoreData

//MARK: - Fetched Results Controller Delegate
extension UITableViewController: NSFetchedResultsControllerDelegate {
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
//        case .move:
//            if let indexPath = indexPath, let newIndexPath = newIndexPath, indexPath != newIndexPath {
//                tableView.deleteRows(at: [indexPath], with: .fade)
//                tableView.insertRows(at: [newIndexPath], with: .fade)
//            }
            
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        default:
            print("...")
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func addPullToRefresh() {
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchData), for: .valueChanged)
    }
    
    @objc func fetchData() {
        
    }
}
