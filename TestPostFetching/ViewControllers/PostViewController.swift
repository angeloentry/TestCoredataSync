//
//  ViewController.swift
//  TestPostFetching
//
//  Created by user167484 on 5/2/20.
//  Copyright © 2020 Allen Savio. All rights reserved.
//

import UIKit
import CoreData

typealias DataFetchCompletion = () -> Void
class PostViewController: UITableViewController {
    //MARK: - Outlets and Properties
    var searchController: UISearchController?
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Post> = {
    // Create Fetch Request
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        fetchRequest.includesPendingChanges = false
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataManager.shared.context!, sectionNameKeyPath: nil, cacheName: nil)

        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    //MARK: - Default Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureUI()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        fetchData()
    }
    
    func configureUI() {
        addPullToRefresh()
        setupSearchController()
    }
    
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        
        let searchBar = searchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for Posts"
        navigationItem.titleView = searchController?.searchBar
        
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.obscuresBackgroundDuringPresentation = false
    }
    
    
    //MARK: - Data Fetcher
    func fetchPosts(completion: @escaping DataFetchCompletion) {
        Request.fetchPosts.execute(success: { (response, posts: [Post]) in
            completion()
        }, failure: { (error) in
            print(error.localizedDescription)
            completion()
        })
    }
    
    override func fetchData() {
        print("In refreshing")
        self.tableView.refreshControl?.beginRefreshing()
        fetchPosts { [weak self] in
            DataManager.shared.saveContext()
            self?.tableView.refreshControl?.endRefreshing()
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedRow = tableView.indexPathForSelectedRow else { return }
        let post = fetchedResultsController.object(at: selectedRow)
        let postObjectID = post.objectID
        let newPost = try? DataManager.shared.context!.existingObject(with: postObjectID) as? Post
        let controller = segue.destination as? CommentsViewController
        controller?.post = newPost
    }
}

//MARK: - Tableview Delegate and Datasource
extension PostViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = fetchedResultsController.object(at: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as? PostTableViewCell else { return UITableViewCell() }
        cell.titleLabel?.text = post.title
        cell.detailLabel?.text = post.body
        return cell
    }
    
}


//MARK: - SearchController Delegate
extension PostViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        var predicate: NSPredicate?
        
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty, searchText.count > 3 {
            predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR body CONTAINS[cd] %@", searchText, searchText)
        } else {
            predicate = nil
        }
        
        fetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch let err {
            print(err)
        }
    }
}
