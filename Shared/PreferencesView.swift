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
    let daysCollection = [1, 3, 7, 30]
    @Binding var showTab: Int
    @State var numberOfDays = UserDefaults.standard.integer(forKey: "numberOfDays") == 0 ? 1 : UserDefaults.standard.integer(forKey: "numberOfDays")
    @State var isAlertOn = false
    @State var alertTitle = ""
    @State var alertImage = ""
    @State var showCard = false
    @State var color: Color = .green
    @EnvironmentObject var notification: CustomNotification
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: Product.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Product.expiryDate, ascending: true)]) var products: FetchedResults<Product>
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Form {
                        Section(header: Text("Reminders")) {
                            Toggle("Remind before product(s) Expire:", isOn: $notification.isNotificationEnabled)                            
                        }
                        Section(header: Text("Delete product after 'x' days of expiry")) {
                            Picker("Select the number of days", selection: $numberOfDays) {
                                ForEach(daysCollection, id: \.self) {
                                    Text("\($0) Days")
                                }
                            }
                        }
                    }
                }
                .alert(isPresented: $isAlertOn) {
                    Alert(title: Text("Saved!"), message: Text("Your Preferences hase been saved successfully!"), dismissButton: .default(Text("OK")))
                }
                .onAppear(perform: {
                   print("on appear")
                    UserDefaults.standard.set(self.numberOfDays == 0 ? 1 : self.numberOfDays, forKey: "numberOfDays")
                    UserDefaults.standard.set(self.notification.isNotificationEnabled, forKey: "isNotificationEnabled")
                })
                .navigationTitle("Preferences")
                .navigationBarItems( trailing: Button("Save") {
                    if notification.isNotificationEnabled {
                        notification.isNotificationEnabled = true
                        notification.notificationRequest()
                        updateProductsandNotifications()
                       
                    }
                    else {
                        notification.isNotificationEnabled = false
                        notification.removeAllNotifications()
                    }
                    for product in products {
                        product.deleteAfter = Int16(numberOfDays)
                    }
                    notification.saveContext(viewContext: viewContext)
                    alertTitle = "Preferences Saved!"
                    alertImage = "checkmark.seal.fill"
                    color = .green
                    withAnimation {
                        showCard = true
                    }
                    UserDefaults.standard.set(self.numberOfDays == 0 ? 1 : self.numberOfDays, forKey: "numberOfDays")
                    UserDefaults.standard.set(!self.notification.isNotificationEnabled, forKey: "isNotificationDisabled")
                })
                if showCard {
                    Card(title: alertTitle, image: alertImage, color: color)
                        .transition(.opacity)
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
    func updateProductsandNotifications() {
        for product in products {
            let result = notification.checkExpiry(expiryDate: product.expiryDate ?? Date().dayAfter, deleteAfter: product.DeleteAfter, product: product)
            notification.handleProducts(viewContext:viewContext, result: result, product: product)
            notification.saveContext(viewContext: viewContext)
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(showTab: .constant(0))
    }
}
