//
//  CustomNotification.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-10-02.
//

import Foundation
import UserNotifications
import CoreData
import CloudKit

class CustomNotification: ObservableObject {
    
    // to make sure whether user has enabled notifications or not
    @Published var isNotificationEnabled: Bool = !UserDefaults.standard.bool(forKey: "isNotificationDisabled")
    
    
    // closure to get dateComponents in day and seconds
    static let dateComponent = { (expiryDate: Date) -> (days:Int?, seconds:Int?) in
        let dayComponent = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate)
        let secondComponent = Calendar.current.dateComponents([.second], from: Date(), to: expiryDate)
        let components = (days: dayComponent.day, seconds:secondComponent.second)
        print()
        return components
    }
    
    init() {
        // get the bool object from Userdefault and store its inverted result to this var.
        isNotificationEnabled = !UserDefaults.standard.bool(forKey: "isNotificationDisabled")
    }
    
   // method to check product expiry and return a string output
   
    
    //method to send notification request
    func notificationRequest() {
        //get the current notification center object
        let center = UNUserNotificationCenter.current()
        
        //method to check if the request is sent to the user or not.
        center.requestAuthorization(options: [.alert,.badge, .sound]) { success, error in
            if success {
                print("Notification request has been set for user to authorize.")
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    //add time trigger notification for a given product.
    func sendTimeNotification(product: Product) {
        
        //date component that will get the seconds passed from this day to product expiry
        print(product.expiryDate.debugDescription.localizedLowercase)
        let expirySeconds = Self.dateComponent(product.expiryDate!).seconds ?? 0
        print("expiry seconds are:\(expirySeconds)")
        
        // get the notification settings that will give back the authorization Status of user notification request.
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            //if user has authorized the request
            if settings.authorizationStatus == .authorized {
                print("----------------Notifications for \(product.getName)----------------")
                // for day of expiry to last red zone day.
                for i in 0...product.redZoneExpiry {
                    // making sure the expiry days seconds are more than the given number of days from expiry.
                   if expirySeconds > i*86400 {
                       // add notification trigger request.
                       self.addRequest(seconds:i*86400, product:product, expirySeconds:expirySeconds)
                       print("for day \(i) from expiry is sent")
                    }
                }
            }
            //if user has not authorized the request yet.
            else if settings.authorizationStatus == .notDetermined {
                //request authoization to user again.
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    print("Notification request is not authorized by the user yet.")
                    // if request is authorized.
                    if success {
                        // add the notification trigger requests.
                        for i in 0...product.redZoneExpiry {
                            if expirySeconds > i*86400 {
                                // call method to create trigger, content and request.
                                self.addRequest(seconds:i*86400, product:product, expirySeconds:expirySeconds)
                            }
                    }
                        print("Notification request has been now sent...")
                    }
                    // if request is not authorized again.
                    else {
                        fatalError((error != nil) ? error!.localizedDescription : "Unknown Error." )
                    }
                }
            }
            // if request is denied by the user exit the function.
            else {
                return
            }
        }
    }
    // add notification request.
    func addRequest(seconds: Int, product: Product, expirySeconds: Int) -> Void {
        // create content body.
        let createContentBody = { (productName: String) -> String in
            if seconds == 0 {
                print("Your product '\(product.getName)' has been expired today!")
                return "Your product '\(product.getName)' has been expired today!"
            }
            else if seconds == 86400 {
                print("Your product '\(product.getName)' is expiring tommorrow!")
                return "Your product '\(product.getName)' is expiring tommorrow!"
            }
            else if seconds == 2*86400 {
                print("Your product '\(product.getName)' is expiring in 2 days!")
               return "Your product '\(product.getName)' is expiring in 2 days!"
            }
            else {
                print("Your product '\(product.getName)' is expiring on \(product.ExpiryDate.capitalized)!")
                return "Your product '\(product.getName)' is expiring on \(product.ExpiryDate.capitalized)!"
            }
        }
        // content object
        let content = UNMutableNotificationContent()
        // content title, body, sound.
        content.title = "Expiry Date Reminder"
        content.body = createContentBody(product.getName)
        content.sound = UNNotificationSound.default
        
        //create a time interval notification trigger from time starting now to red zone days.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(expirySeconds - seconds), repeats: false)
        print("trigger seconds are: \(TimeInterval(expirySeconds - seconds))")
        //send the by unique id, content and trigger
        let request = UNNotificationRequest(identifier: "\(product.getProductID)\(seconds)", content: content, trigger: trigger)
        print("ID is \(product.getProductID)\(seconds)")
        //add all such requests to notification center object.
        UNUserNotificationCenter.current().add(request) { error in
            guard let error = error else {
                print("request added.")
                return
            }
            fatalError(error.localizedDescription)
        }
        
    }
    //remove a selected product notification
    func removeNotification(product: Product) {
        // array of given productIDs.
        var productIDs: [String] = []
        // loop through number of red zone days
        for i in 0...product.redZoneExpiry {
            // add ids of each redZone day of given product to array.
            productIDs.insert("\(product.getProductID)\(i*86400)", at: i)
        }
        
        // delete all pending notifications for given productIDs.
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: productIDs)
        
        //delete all delivered notifications for given productIDs.
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: productIDs)
      
        print("product notification is deleted for \(product.getName) with id: \(product.getProductID)")
    }
    
    //remove all notifications from notification center.
    func removeAllNotifications() {
        
        //delete all delivered notifications.
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        // delete all pending notifications.
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        print("All product notification is deleted...")
    }
    
    //method that prints list of notifications and returns number pending notifications.
    func listOfPendingNotifications() -> Int {
        var counts = 0
        // get all pending notification request objects.
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
            print("number of pending notifications are \(notifications.count)")
            // count the array length
            counts = notifications.count
            
            print("---------------List of Notifications----------------")
            //iterate through all notification objects
            for notification in notifications {
                //print notification content body.
                print(notification.content.body)
            }
        }
        return counts
    }

}

