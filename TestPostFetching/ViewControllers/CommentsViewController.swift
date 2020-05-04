//
//  CommentsViewController.swift
//  TestPostFetching
//
//  Created by user167484 on 5/3/20.
//  Copyright © 2020 Allen Savio. All rights reserved.
//

import UIKit
import CoreData

class CommentsViewController: UITableViewController {
    //MARK: - Outlets and Properties
    var post: Post!
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Comment> = {
        // Create Fetch Request
            let fetchRequest: NSFetchRequest<Comment> = Comment.fetchRequest()
            fetchRequest.includesPendingChanges = false
            // Configure Fetch Request
            fetchRequest.predicate = NSPredicate(format: "postId == %d", post.id)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

            // Create Fetched Results Controller
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataManager.shared.context!, sectionNameKeyPath: nil, cacheName: nil)

            // Configure Fetched Results Controller
            fetchedResultsController.delegate = self
            return fetchedResultsController
        }()
      
    //MARK: - Default Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        fetchData()
        try? fetchedResultsController.performFetch()
    }
    
    //MARK: - Data Fetcher
    func fetchComments(postId: Int, completion: @escaping DataFetchCompletion) {
        Request.fetchComments(postId: postId).execute(success: {  (response, comments: [Comment]) in
            completion()
        }, failure: { (error) in
            print(error)
            completion()
        })
    }
    
    override func fetchData() {
        print("In refreshing")
        self.tableView.refreshControl?.beginRefreshing()
        fetchComments(postId: Int(post.id)) { [weak self] in
            DataManager.shared.saveContext()
            self?.tableView.refreshControl?.endRefreshing()
        }
    }
    
    
    // MARK: - Tableview Datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }

        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = fetchedResultsController.object(at: indexPath)
        let cell =  tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentsTableViewCell
        cell.nameLabel.text = comment.name
        cell.emailLabel.text = comment.email
        cell.commentLabel.text = comment.body
        return cell
    }
}
