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
                notification.removeAllNotifications()
                notification.notificationRequest()
                for product in products {
                    let result = notification.checkExpiry(expiryDate: product.expiryDate ?? Date(), deleteAfter: product.DeleteAfter, product: product)
                    notification.handleProducts(viewContext:viewContext, result: result, product: product)
                    notification.saveContext(viewContext: viewContext)
                }
            })
            .onDisappear(perform: {
                notification.notificationRequest()
                notification.removeAllNotifications()
                for product in products {                                       
                    let result = notification.checkExpiry(expiryDate: product.expiryDate ?? Date(), deleteAfter: product.DeleteAfter, product: product)
                    notification.handleProducts(viewContext:viewContext, result: result, product: product)
                    notification.saveContext(viewContext: viewContext)
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
            PreferencesView()
                .tabItem {
                    Image(systemName: "gearshape.2.fill")
                    Text("Preferences")
                }
        }
        .environmentObject(notification)
                
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
        notification.saveContext(viewContext: viewContext)
        productName = ""
        expiryDate = Date()
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
