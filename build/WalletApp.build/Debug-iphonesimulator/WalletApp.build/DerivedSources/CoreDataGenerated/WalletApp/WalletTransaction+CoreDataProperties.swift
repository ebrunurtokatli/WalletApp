//
//  WalletTransaction+CoreDataProperties.swift
//  
//
//  Created by Trakya11 on 9.05.2025.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension WalletTransaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalletTransaction> {
        return NSFetchRequest<WalletTransaction>(entityName: "WalletTransaction")
    }

    @NSManaged public var amount: Double
    @NSManaged public var category: String?
    @NSManaged public var date: Date?
    @NSManaged public var isIncome: Bool

}

extension WalletTransaction : Identifiable {

}
