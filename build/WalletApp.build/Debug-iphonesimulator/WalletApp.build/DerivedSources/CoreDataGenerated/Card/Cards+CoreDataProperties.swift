//
//  Cards+CoreDataProperties.swift
//  
//
//  Created by Trakya11 on 9.05.2025.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Cards {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cards> {
        return NSFetchRequest<Cards>(entityName: "Cards")
    }

    @NSManaged public var cardNumber: String?
    @NSManaged public var cvv: String?
    @NSManaged public var expirationDate: String?
    @NSManaged public var name: String?

}

extension Cards : Identifiable {

}
