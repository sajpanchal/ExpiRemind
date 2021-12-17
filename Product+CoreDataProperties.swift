//
//  Product+CoreDataProperties.swift
//  NotifyExpiryDate (iOS)
//
//  Created by saj panchal on 2021-09-26.
//
//

import Foundation
import CoreData
import SwiftUI


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
    @NSManaged public var isNotificationSet: Bool
    
    public var getProductID: String {
        return "\(productID ?? UUID())"
    }
    
    public var getName: String {
        name?.trimmingCharacters(in: .whitespaces) ?? "N/A"
    }
    
    
    public var getType: String {
        type ?? "N/A"
    }
    public var IsNotificationSet: Bool {
        return isNotificationSet
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
       
        case 90...:
            return 30
        case 7..<90:
            return 7
        case 2..<7:
            return 2
        default:
            return 2
        }
    }
    
    public var yellowZoneExpiry: Int {
        let dateComponent = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate ?? Date())
        
        switch dateComponent.day! {
        case 90... :
            return 50
        case 30..<90:
            return 20
        case 7..<90:
            return 5
        case 2..<7:
            return 4
        default:
            return 4
        }       
    }
    
    //date formatter with format mm/dd/yyyy
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    //time formatter with format hh:mm AM/PM
    static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
    static var dateAndTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    static func saveContext(viewContext: NSManagedObjectContext) {
        do {
            try viewContext.save()
            print("product is saved in cloudKit.")
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func checkExpiry(expiryDate: Date, deleteAfter: Int, product: Product) -> String {
        // if day is not nil
        if let days = CustomNotification.dateComponent(expiryDate).days {
             // if Expiry date is passed
             if days < 0 {
                 // if product's deletion days are passed.
                 if abs(days) >= deleteAfter {
                     return "Delete"
                 }
                 // otherwise
                 else {
                     return "Expired"
                 }
             }
             // if product Expiry date is not passed yet.
             else {
                 // if expiry date is in red zone
                 if days <= product.redZoneExpiry {
                     return "Near Expiry"
                 }
                 // if expiry date is in yellow zone.
                 else if days <= product.yellowZoneExpiry && days > product.redZoneExpiry {
                     return "Far From Expiry"
                 }
                 //if expiry date is in green zone
                 else {
                     return "Alive"
                 }
             }
        }
         return "Undefined"
     }
    
    static func handleProducts(viewContext: NSManagedObjectContext, result: String, product: Product, notification:CustomNotification) {
        switch result {
            //remove the product notification and delete from core data
            case "Delete" :
            notification.removeNotification(product: product)
                viewContext.delete(product)
            Product.saveContext(viewContext: viewContext)
            // once notification is sent
            case "Near Expiry":
            print("")
            case "Expired":
            notification.removeNotification(product: product)
                break
        case "Alive":
            print("")
            default:
            break
        }
    }
   static func modifyDate(date: Date) -> Date {
       print("----------modifyDate--------------")
    let reminderTime = (UserDefaults.standard.object(forKey: "reminderTime") as? Date) ?? Date(timeIntervalSinceReferenceDate: -25200)
       print("reminder time", reminderTime )
       let reminderTimeString = timeFormatter.string(from: reminderTime)
       print("reminder time string", reminderTimeString )
      
       let dateStr:String = dateFormatter.string(from: date)
       print("product actual date",dateStr)
        let modifiedDateStr = "\(dateStr) at \(reminderTimeString)"
        print("Modified Date String is : \(modifiedDateStr)")
    
       let modifiedDate: Date = dateAndTimeFormatter.date(from: modifiedDateStr)!
        print("modified date:", modifiedDate)
        return modifiedDate
    }
    
    static func checkNumberOfReminders(products: FetchedResults<Product>) -> Int {
        var counter = 0
        for prod in products {
            if prod.isNotificationSet == true {
                counter += 1
            }
        }
        return counter
    }
    
    

}

extension Product : Identifiable {

}
