//
//  Product+CoreDataProperties.swift
//  NotifyExpiryDate (iOS)
//
//  Created by saj panchal on 2021-09-26.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var dateStamp: Date?
    @NSManaged public var expiryDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var deleteAfter: Int16
   
    
    public var getName: String {
        name ?? "N/A"
    }
    
    public var getType: String {
        type ?? "N/A"
    }
    
    public var ExpiryDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // Jan 1, 2021
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: expiryDate ?? Date())
    }
    
    public var DateStamp: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .long
        
        return dateFormatter.string(from: dateStamp ?? Date())
    }
    public var DeleteAfter: Int {
        if deleteAfter == 0 {
            return 30
        }
        else {
            return Int(deleteAfter)
        }
    }
    
    

}

extension Product : Identifiable {

}
