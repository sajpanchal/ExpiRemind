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
    @NSManaged public var productID: UUID?
    
    public var getProductID: String {
        return "\(productID ?? UUID())"
    }
    
    public var getName: String {
        name?.trimmingCharacters(in: .whitespaces) ?? "N/A"
    }
    
    
    public var getType: String {
        type ?? "N/A"
    }
    
    public var ExpiryDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // Jan 1, 2021
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: expiryDate ?? Date().dayAfter)
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
    
    public var redZoneExpiry: Int {
        let dateComponent = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate ?? Date())
        
        switch dateComponent.day! {
        case 180... :
            return 30
        case 90..<180:
            return 15
        case 30..<90:
            return 10
        case 15..<30:
            return 5
        case 7..<15:
            return 2
        default:
            return 2
        }
    }
    
    public var yellowZoneExpiry: Int {
        let dateComponent = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate ?? Date())
        
        switch dateComponent.day! {
        case 180... :
            return 60
        case 90..<180:
            return 30
        case 30..<90:
            return 15
        case 15..<30:
            return 10
        case 7..<15:
            return 4
        default:
            return 4
        }       
    }
    
    

}

extension Product : Identifiable {

}
