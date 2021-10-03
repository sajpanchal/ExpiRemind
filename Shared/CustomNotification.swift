//
//  CustomNotification.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-10-02.
//

import Foundation
import UserNotifications
import CoreData


class CustomNotification {
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
        
    }
    
    var date: DateComponents {
        var date = DateComponents()
        date.hour = 8
        date.minute = 30
        return date
    }
    
    func checkExpiry(expiryDate: Date, deleteAfter: Int, product: Product) -> String {
        let diff = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate)
            if let days = diff.day {
                print("\n------------------------\(product.id)-----------------------------")
                print("name: ",product.getName)
                print("expiry date:",product.ExpiryDate)
                print("today is: \(Date())")
                print("days to expiry:",days)
                print(product.ExpiryDate)
                // Expiry date is passed
                if days < 0 {
                    // deletion days are passed.
                    if abs(days) >= deleteAfter {
                        return "Delete"
                    }
                    //deletion days are yet to be passed.
                    else {
                        return "Expired"
                    }
                }
                // Expiry date is not passed yet.
                else {
                    // expiry date is 3 or less days away.
                    if days <= 3 {
                        print("\(product.getName)")
                        
                            sendNotification(product: product)
                            print("calling notifcation for \(product.getName)")
                        return "Near Expiry"
                    }
                    //expiry date is far away.
                    else {
                        return "Alive"
                    }
                }
            }
        return "Undefined"
    }
    
    func notificationRequest() {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert,.badge, .sound]) { success, error in
                if success {
                    print("Notification request has been set for user to authorize.")
                }
                else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    
    func sendNotification(product: Product) {
        let content = UNMutableNotificationContent()
        content.title = "\(product.getName) is expiring soon!"
        content.subtitle = "\(product.getName) expiring \(product.ExpiryDate == dateFormatter.string(from: Date()) ? "today.": "on \(product.ExpiryDate).")"
        content.sound = UNNotificationSound.default
        let addRequest =  {
            let trigger = UNCalendarNotificationTrigger(dateMatching: self.date, repeats: true)
            let request = UNNotificationRequest(identifier: "\(product.id)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                guard let error = error else {
                    return
                }
                fatalError(error.localizedDescription)
            }
           
        }
        
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    addRequest()
                   
                    print("Notification request has been sent...")
                    
                }
                else if settings.authorizationStatus == .notDetermined {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    print("Notification request is not authorized by the user yet.")
                    if success {
                            addRequest()
                           
                            print("Notification request has been now sent...")
                        }
                    else {
                       
                            fatalError((error != nil) ? error!.localizedDescription : "Unknown Error." )
                        }
                    }
                }
                else {
                    return
                }
            }
        
        
     
        
    }
    func removeNotification(product: Product) {
            
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["\(product.id)"])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(product.id)"])
    print("product notification is deleted for \(product.getName)")
    }
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All product notification is deleted...")
    }
    
    func saveContext(viewContext: NSManagedObjectContext) {
        do {
            try viewContext.save()
            print("product is saved.")
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    func handleProducts(viewContext: NSManagedObjectContext, result: String, product: Product) {
        print("result for \(product.getName) is: \(result)")
        switch result {
            //remove the product notification and delete from core data
            case "Delete" :
            removeNotification(product: product)
                viewContext.delete(product)
            // once notification is sent
            case "Near Expiry":
                print("\(product.getName): is Near Expiry")
            case "Expired":
            removeNotification(product: product)
                break
        case "Alive":
            print("\(product.getName): is Alive")
            default:
            break
        }
    }
}
