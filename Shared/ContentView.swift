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
    
    var date: DateComponents {
        var date = DateComponents()
        date.hour = 8
        date.minute = 0
        return date
    }
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
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
                    prepareAlertContent(title: "Discarded!", message: "New Product has been discarded successfully.")
                   
                }
                .foregroundColor(.red), trailing: Button("Done") {
                    if productName.count >= 2 {
                        addProduct()
                        prepareAlertContent(title: "Saved!", message: "New Product has been saved successfully.")
                    }
                    else {
                        prepareAlertContent(title: "Something went wrong!", message: "Please enter the product name with atleast 2 characters length. Make sure to set its type and expiry date too!")
                    }
                })
                .navigationBarTitle("Add New Product")
            }
            .onAppear(perform: {
                notificationRequest()
                for product in products {
                    if checkExpiry(expiryDate: product.expiryDate ?? Date(), deleteDays: product.DeleteAfter, product: product) {
                        viewContext.delete(product)
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
    
    func prepareAlertContent(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
   
    func checkExpiry(expiryDate: Date, deleteDays: Int, product: Product) -> Bool {
            let diff = Calendar.current.dateComponents([.day], from: expiryDate, to: Date())
            if let days = diff.day {
                if days >= deleteDays {
                    return true
                }
                else {
                    if abs(days) <= 3 {
                        sendNotification(product: product)
                    }
                    return false
                }
            }
            
        return false
    }
    func sendNotification(product: Product) {
        
        let content = UNMutableNotificationContent()
        content.title = "\(product.getName) is expiring soon!"
        content.subtitle = "\(product.getName) expiring \(product.ExpiryDate == dateFormatter.string(from: Date()) ? "today.": "on \(product.ExpiryDate).")"
        content.sound = UNNotificationSound.default
        
        let addRequest =  {
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) {error in
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
            else {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    print("request is not added yet.")
                    if success {
                        addRequest()
                        print("request is now added.")
                    }
                    else {
                        fatalError(error!.localizedDescription)
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
                let isExpired = checkExpiry(expiryDate: product.expiryDate ?? Date(), deleteDays: product.DeleteAfter, product: product)
                print(isExpired)
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
