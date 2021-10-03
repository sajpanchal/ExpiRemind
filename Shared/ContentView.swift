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
    var notification = CustomNotification()
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
        date.minute = 30
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
                notification.notificationRequest()
                for product in products {
                    print("name: ",product.getName)
                    print("expiry date:",product.ExpiryDate)
                    print("is subscribed:", product.isNotificationSet)
                    
                    let result = notification.checkExpiry(expiryDate: product.expiryDate ?? Date(), deleteAfter: product.DeleteAfter, product: product)
                    print("result for \(product.getName) is: \(result)")
                    switch result {
                        case "Expired" :
                            viewContext.delete(product)
                        case "Near Expiry":
                            product.isNotificationSet = true
                        case "Undefined":
                            break
                        default:
                        break
                    }
                        do {
                            try viewContext.save()
                            print("\(product.getName) is saved.")
                        }
                        catch {
                            fatalError(error.localizedDescription)
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
    
    
    func prepareAlertContent(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
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
