//
//  CustomNotification.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-10-02.
//

import Foundation
import UserNotifications
import CoreData


class CustomNotification: ObservableObject {
    @Published var isNotificationEnabled: Bool = !UserDefaults.standard.bool(forKey: "isNotificationDisabled")
      
    var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter
            
        }
    init() {

        isNotificationEnabled = !UserDefaults.standard.bool(forKey: "isNotificationDisabled")
        print("initilier called: ", isNotificationEnabled)
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
                        if self.isNotificationEnabled {
                            print("calling notifcation for \(product.getName)")
                        }
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
            
    func sendTimeNotification(product: Product) {
        let timeInterval = Calendar.current.dateComponents([.second], from: Date(), to: product.expiryDate!)
        print("expiry Date: \(product.expiryDate!)")
        print("today: \(Date())")
        print("difference: \(timeInterval.second!)")
       
        let addRequest =  { (seconds: Int) -> Void in
            let content = UNMutableNotificationContent()
            content.title = "Expiry Date Reminder"
            if seconds == 0 {
                content.body = "Your product '\(product.getName)' has been expired today!"
            }
            else if seconds == 86400 {
                content.body = "Your product '\(product.getName)' is expiring soon tommorrow!"
            }
            else {
                content.body = "Your product '\(product.getName)' is expiring soon in 2 days!"
            }

            
            content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval.second! - seconds), repeats: false)
        //    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
            let request = UNNotificationRequest(identifier: "\(product.id)\(seconds)", content: content, trigger: trigger)
            print("trigger for \(timeInterval.second! - seconds) secs.")
            UNUserNotificationCenter.current().add(request) { error in
                guard let error = error else {
                    return
                }
                fatalError(error.localizedDescription)
            }
           
        }
        
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    addRequest(0)
                    if timeInterval.second! > 86400 {
                        addRequest(86400)
                    }
                    if timeInterval.second! > (2*86400) {
                        addRequest(2*86400)
                    }
                    
                    print("Notification request has been sent...")
                    
                }
                else if settings.authorizationStatus == .notDetermined {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    print("Notification request is not authorized by the user yet.")
                    if success {
                        addRequest(0)
                        addRequest(86400)
                        addRequest(2*86400)
                           
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
            
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["\(product.id)\(0)"])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(product.id)\(0)"])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["\(product.id)\(86400)"])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(product.id)\(86400)"])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["\(product.id)\(2*86400)"])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(product.id)\(2*86400)"])
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
