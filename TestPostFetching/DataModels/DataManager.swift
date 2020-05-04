//
//  DataManager.swift
//  TestPostFetching
//
//  Created by user167484 on 5/2/20.
//  Copyright © 2020 Allen Savio. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataManager {
    private init() {}
    static let shared = DataManager()
    
    //Used For mocking offline funcionality in Request.swift
    var isNetworkAvailable = true
    
    lazy var persistentContainer: NSPersistentContainer = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer
    }()
    
    lazy var context: NSManagedObjectContext? = {
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    func saveContext () {
        guard let context = self.context else { return }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
        
}
