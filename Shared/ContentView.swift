//
//  ContentView.swift
//  Shared
//
//  Created by saj panchal on 2021-09-19.
//

import SwiftUI
import CoreData
import UserNotifications

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Product.entity(), sortDescriptors: []) var products: FetchedResults<Product>
    let productTypes = ["Document","Electronics","Grocery","Subscription", "Other"]
    let daysCollection = [1, 3, 7, 30]
    @State var numberOfDays = 30
    @State var productName: String = ""
    @State var productType = "Grocery"
    @State var expiryDate = Date()
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var showAlert = false
    
    var body: some View {
        TabView() {
            NavigationView {
                VStack {
                    Form {
                        Section(header: Text("Product Name")) {
                            TextField("Enter Product Name", text:$productName)
                        }
                        Section(header: Text("Product Type")) {
                            Picker("Select Product Type", selection: $productType) {
                                ForEach(productTypes, id: \.self) {
                                    Text($0)
                                }
                            }
                        }
                        Section(header:Text("Expiry Date")) {
                            DatePicker(selection: $expiryDate, in: Date()..., displayedComponents: .date) {
                                Text("Set Expiry Date")
                            }
                        }
                        Section(header: Text("Delete after number of days expiry")) {
                            Picker("Select the number of days", selection: $numberOfDays) {
                                ForEach(daysCollection, id: \.self) {
                                    Text("\($0) Days")
                                }
                            }
                        }
                    }
                }
                .navigationBarItems(leading:Button("Discard") {
                    productName = ""
                    expiryDate = Date()
                    productType = "Grocery"
                    alertTitle = "Discarded!"
                    alertMessage = "New Product has been discarded successfully."
                    showAlert = true
                }
                .foregroundColor(.red), trailing: Button("Done") {
                    if productName.count >= 2 {
                        addProduct()
                        alertTitle = "Saved!"
                        alertMessage = "New Product has been saved successfully."
                        showAlert = true
                        
                    }
                    else {
                        alertTitle = "Something went wrong!"
                        alertMessage = "Please enter the product name with atleast 2 characters length. Make sure to set its type and expiry date too!"
                        showAlert = true
                    }
                })
                .navigationBarTitle("Add New Product")
            }
            .onAppear(perform: {
                for product in products {
                    print(product.getName)
                    if checkExpiry(expiryDate: product.expiryDate ?? Date(), deleteDays: product.DeleteAfter, product: product) {
                        viewContext.delete(product)
                        print("product deleted..")
                        print("name:", product.getName)
                        print("expiry:", product.ExpiryDate)
                        print("delete after:", product.DeleteAfter)
                        do {
                            try viewContext.save()
                            
                        }
                        catch {
                            fatalError(error.localizedDescription)
                        }
                    }
                }
               
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            ProductsListView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("List")
            
                }
        }
                
    }
    func notificationRequest() -> Bool {
        var result = false
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert,.badge, .sound]) { success, error in
            if success {
                print("all set")
               result = true
            }
            else if let error = error {
                print(error.localizedDescription)
             result = false
            }
           
        }
        print(result)
        return result
    }
    func checkExpiry(expiryDate: Date, deleteDays: Int, product: Product) -> Bool {
            let diff = Calendar.current.dateComponents([.day], from: expiryDate, to: Date())
            if let days = diff.day {
                if days >= deleteDays {
                    print("passed. difference is: ",diff.day!)
                    print("days = \(diff.day!), deleteDays = \(deleteDays)")
                   
                    return true
                }
                else {
                    print("failed. difference is: ",diff.day!)
                    print("days = \(diff.day!), deleteDays = \(deleteDays)")
                    if abs(days) <= 3 {
                        let content = UNMutableNotificationContent()
                        content.title = "Your product is expiring soon!"
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.timeStyle = .none
                        content.subtitle = "\(product.getName) expiring \(product.ExpiryDate == formatter.string(from: Date()) ? "today.": "on \(product.ExpiryDate).")"
                        content.sound = UNNotificationSound.default
                        
                            sendNotification(content: content)
                        
                        
                    }
                    return false
                }
            }
            
        return false
    }
    func sendNotification(content: UNMutableNotificationContent) {
  
        print("notification sent")
        var date = DateComponents()
        date.hour = 8
        date.minute = 30
        //let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let addRequest =  {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) {error in
                guard let error = error else {
                    return
                }
                print(error.localizedDescription)
            }
        }
      
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                print("request is added.")
                addRequest()
            }
            else {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    }
                    else {
                        print("something went wrong")
                    }
                }
            }
        }
    }
    func addProduct() {
        let product = Product(context: viewContext)
        product.name = productName
        product.type = productType
        product.expiryDate = expiryDate
        product.dateStamp = Date()
        product.deleteAfter = Int16(numberOfDays)
        
        do {
            try viewContext.save()
            print("product saved")
           
            for product in products {
                checkExpiry(expiryDate: product.expiryDate ?? Date(), deleteDays: product.DeleteAfter, product: product)
                print(product)
            }
        }
        catch {
            fatalError(error.localizedDescription)
        }
        productName = ""
        expiryDate = Date()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
