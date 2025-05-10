//
//  WalletTransaction+CoreDataProperties.swift
//  WalletApp
//
//  Created by Trakya12 on 10.05.2025.
//
//

import Foundation
import CoreData


extension WalletTransaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalletTransaction> {
        return NSFetchRequest<WalletTransaction>(entityName: "WalletTransaction")
    }

    @NSManaged public var amount: Double
    @NSManaged public var date: Date?
    @NSManaged public var category: String?
    @NSManaged public var isIncome: Bool

}

extension WalletTransaction : Identifiable {

}
