//
//  PreferancesView.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-10-04.
//

import SwiftUI
import CoreData
import CloudKit

struct PreferencesView: View {
    //cloudkit managed object context
    @Environment(\.managedObjectContext) var viewContext
    //cloudkit fetched records from Product entity.
    @FetchRequest(entity: Product.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Product.expiryDate, ascending: true)]) var products: FetchedResults<Product>
    
    //shared notification object to manipute products' notifications
    @EnvironmentObject var notification: CustomNotification
    
    //array to display days after expiry date to delete product
    let daysCollection = [1, 3, 7, 30]
    //binding variable that will hold the picker selection value. if already set it will get the set value from user defaults.
    @State var numberOfDays = UserDefaults.standard.integer(forKey: "numberOfDays") == 0 ? 1 : UserDefaults.standard.integer(forKey: "numberOfDays")
    
    //variables to manipulate alert view
    @State var alertTitle = ""
    @State var alertImage = ""
    @State var color: Color = .green
    
    //show/hide card or alert view.
    @State var showCard = false
   
    
    //variable to show which tab view
    @Binding var showTab: Int
    
    //set the reminder time from user default object value.
    @State var reminderTime: Date = (UserDefaults.standard.object(forKey: "reminderTime") as? Date)!
  
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // preferences form
                    Form {
                        //input to enable/disable notification
                        Section(header: Text("Enable Notifications:")) {
                            //toggle switch that will set/reset notification property.
                            Toggle("Product Expiry Reminder", isOn: $notification.isNotificationEnabled)
                        }
                        //input to set reminder time
                        Section(header: Text("Reminder Time:")) {
                            //date picker that will allow user to set time and it will be stored in a variable
                            DatePicker("Set Reminder At", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .accentColor(.secondary)
                        }
                        //input to set deletion day after expiry of product.
                        Section(header: Text("Delete Expired Product:")) {
                            // picker with a selection variable
                            Picker("Delete Product(s) After", selection: $numberOfDays) {
                                //disply picker content from array of days.
                                ForEach(daysCollection, id: \.self) {
                                    Text("\($0) Days")
                                }
                            }
                        }
                        VStack{
                            Button {
                                // if notification is enabled.
                                if notification.isNotificationEnabled {
                                    
                                    print("notification now enabled.")
                                    //set the reminder time
                                    setReminderTime()
                                    
                                    // set the flag redundantly.
                                    notification.isNotificationEnabled = true
                                    
                                    // now send the notification request to add updated notifications for all products.
                                    notification.notificationRequest()
                                    
                                    // if notifications are previously deleted.
                                    if notification.listOfPendingNotifications() == 0 {
                                        //create new notifications for all products.
                                        updateProductsandNotifications()
                                    }
                                }
                                else {
                                    //reset the flag.
                                    notification.isNotificationEnabled = false
                                    //remove all pending or delivered notifications of all products.
                                    notification.removeAllNotifications()
                                }
                                
                                //set the deletion days.
                                for product in products {
                                    product.deleteAfter = Int16(numberOfDays)
                                }
                                //save the products context with latest updates to cloudkit
                                Product.saveContext(viewContext: viewContext)
                                
                                //set card view appearance.
                                alertTitle = "Preferences Saved!"
                                alertImage = "checkmark.seal.fill"
                                color = .green
                                
                                //show it with animation
                                withAnimation {
                                    showCard = true
                                }
                                UserDefaults.standard.set(self.numberOfDays == 0 ? 1 : self.numberOfDays, forKey: "numberOfDays")
                                UserDefaults.standard.set(!self.notification.isNotificationEnabled, forKey: "isNotificationDisabled")
                            }
                        label: {
                            HStack {
                                Spacer()
                                
                                Text("Save")
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .frame(height: 50, alignment: .center)
                        }
                            .background(Color.gray)
                            .buttonStyle(BorderlessButtonStyle())
                            .cornerRadius(10)
                            .padding(.bottom, 10)
                            Button {
                                numberOfDays = UserDefaults.standard.integer(forKey: "numberOfDays") == 0 ? 1 : UserDefaults.standard.integer(forKey: "numberOfDays")
                              print("number of days:", numberOfDays)
                                print("user defaults", UserDefaults.standard.integer(forKey: "numberOfDays"))
                            reminderTime = (UserDefaults.standard.object(forKey: "reminderTime") as? Date)!
                                notification.isNotificationEnabled =   !(UserDefaults.standard.bool(forKey: "isNotificationDisabled"))
                                
                                //set card view appearance.
                                alertTitle = "Preferences discards!"
                                alertImage = "xmark.seal.fill"
                                color = .red
                                
                                //show it with animation
                                withAnimation {
                              //      showCard = true
                                }
                            }
                        label: {
                            HStack {
                                Spacer()
                                
                                Text("Discard")
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .frame(height: 50, alignment: .center)
                        }
                            .background(Color.red)
                            .buttonStyle(BorderlessButtonStyle())
                            .cornerRadius(10)
                            .padding(.bottom, 10)
                            
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                        
                    }
                }
                //when this view appears.
                .onAppear(perform: {
                   print("on appear")
                    print(UserDefaults.standard.integer(forKey: "numberOfDays"))
                    //save number of days to default value if it is not set or keep the default value and save it to user defaults.
                 //   UserDefaults.standard.set(self.numberOfDays == 0 ? 1 : self.numberOfDays, forKey: "numberOfDays")
                    //save the notification enabling flag to its default value in user defaults.
                  //  UserDefaults.standard.set(self.notification.isNotificationEnabled, forKey: "isNotificationEnabled")
                
                })
                .navigationTitle("Preferences")
                //save button
               
                //show the card if flag is set
                if showCard {
                    Card(title: alertTitle, image: alertImage, color: color)
                    //with animation change card view opacity
                        .transition(.opacity)
                    
                    //after 3 seconds hide the card.
                    let _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
                        withAnimation {
                        showCard = false
                         showTab = 0
                        }
                    }
                }
            }
        }
    }
    func setReminderTime() {
        //first remove all old notifications of all products.
        notification.removeAllNotifications()
        
        //set the new reminder time in user defaults.
        UserDefaults.standard.set(reminderTime, forKey: "reminderTime")
    }
    func updateProductsandNotifications() {
        print("update products and notifications.")
        //iterate through all products
        for product in products {
            // modify expiry date to offseted time of that exipry date.
            product.expiryDate = Product.modifyDate(date: product.expiryDate!)
            print("\(product.getName) expiry date is \(product.expiryDate!)")
            
            //create a notification trigger request with content for that product.
            notification.sendTimeNotification(product: product)
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(showTab: .constant(0))
    }
}
