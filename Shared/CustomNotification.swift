//
//  CustomNotification.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-10-02.
//

import Foundation
import UserNotifications
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
                print("days:",days)
                print(product.ExpiryDate)
                // if today is after expiry
                if days < 0 {
                    if abs(days) >= deleteAfter {
                        return "Expired"
                    }
                }
                // if today is before expiry
                else {
                    if days <= 3 {
                        print("\(product.getName):  \(product.isNotificationSet)")
                        if !product.isNotificationSet {
                            sendNotification(product: product)
                            print("calling notifcation for \(product.getName)")
                                return "Near Expiry"
                        }
                    }
                    return "Undefined"
                }
            }
            
        return "Undefined"
    }
    
    func notificationRequest() {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert,.badge, .sound]) { success, error in
                if success {
                    print("all set")
                
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
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                guard let error = error else {
                    return
                }
                fatalError(error.localizedDescription)
            }
           
        }
      
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                print("request is added.")
                addRequest()
                
            }
            else if settings.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                print("request is not added yet.")
                if success {
                    addRequest()
                    print("request is now added.")
                   
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
}
