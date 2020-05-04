//
//  Post+CoreDataClass.swift
//  TestPostFetching
//
//  Created by user167484 on 5/3/20.
//  Copyright © 2020 Allen Savio. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Post)
public class Post: NSManagedObject, Codable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case body = "body"
        case title = "title"
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Post", in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int64.self, forKey: .id) ?? 0
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.body = try container.decodeIfPresent(String.self, forKey: .body) ?? ""
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
    }
}
