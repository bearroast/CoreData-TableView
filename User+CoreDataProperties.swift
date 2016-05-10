//
//  User+CoreDataProperties.swift
//  CoreData TableView
//
//  Created by Bjorn Eivind Rostad on 5/1/16.
//  Copyright © 2016 bearroast. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {
    
    @NSManaged var name: String?
    
}
