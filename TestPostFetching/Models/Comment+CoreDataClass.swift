//
//  Comment+CoreDataClass.swift
//  TestPostFetching
//
//  Created by user167484 on 5/3/20.
//  Copyright © 2020 Allen Savio. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Comment)
public class Comment: NSManagedObject, Codable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case postId = "postId"
        case name = "name"
        case email = "email"
        case body = "body"
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Comment", in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int64.self, forKey: .id) ?? 0
        self.postId = try container.decodeIfPresent(Int64.self, forKey: .postId) ?? 0
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.body = try container.decodeIfPresent(String.self, forKey: .body) ?? ""
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(id, forKey: .postId)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(body, forKey: .body)
    }
}


public extension CodingUserInfoKey {
    // Helper property to retrieve the Core Data managed object context
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}
