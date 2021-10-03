//
//  EditProductView.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-09-24.
//

import SwiftUI
import CoreData
struct EditProductView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: Product.entity(), sortDescriptors: []) var products: FetchedResults<Product>
    @ObservedObject var product: Product
    let productTypes = ["Document","Electronics","Grocery","Subscription", "Other"]
    let daysCollection = [1, 3, 7, 30]
    let notification = CustomNotification()
    @State var numberOfDays: Int
    @State var productName: String
    @State var productType: String
    @State var expiryDate: Date
    
    var body: some View {
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
            Button("Save Changes") {
                // save the product changes, remove notification of old changes.
                saveChanges()
                notification.removeAllNotifications()
                notification.notificationRequest()
                
                for product in products {
                    let result = notification.checkExpiry(expiryDate: product.expiryDate ?? Date(), deleteAfter: product.DeleteAfter, product: product)
                    notification.handleProducts(viewContext: viewContext,result: result, product: product)
                    notification.saveContext(viewContext: viewContext)
                }
            }
            Spacer()
        }
        .navigationTitle("Edit Product")
        .navigationBarItems(trailing: Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                                .onTapGesture(perform: deleteProduct))
        .onDisappear(perform: {
            presentationMode.wrappedValue.dismiss()
        })
        
    }
    /*func saveContext() {
        do {
            try viewContext.save()
            print("product is saved.")
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }*/
    /*func handleProducts(result: String, product: Product) {
        print("result for \(product.getName) is: \(result)")
        switch result {
            //remove the product notification and delete from core data
            case "Delete" :
            notification.removeNotification(product: product)
                viewContext.delete(product)
            // once notification is sent
            case "Near Expiry":
                print("\(product.getName): is Near Expiry")
            case "Expired":
            notification.removeNotification(product: product)
                break
        case "Alive":
            print("\(product.getName): is Alive")
            default:
            break
        }
    }*/
    
    func saveChanges() {
        if let prod = products.first(where: {$0.DateStamp == product.DateStamp})  {
            notification.removeNotification(product: product)
            prod.name = productName
            prod.type = productType
            prod.expiryDate = expiryDate
            prod.dateStamp = Date()
            prod.deleteAfter = Int16(numberOfDays)
            notification.saveContext(viewContext: viewContext)
            // dismiss the view.
            presentationMode.wrappedValue.dismiss()
        }
    }
    func deleteProduct() {
        viewContext.delete(product)
        notification.saveContext(viewContext: viewContext)
        resetFormInputs()
        presentationMode.wrappedValue.dismiss()
    }
    func resetFormInputs() {
        productName = ""
        productType = "Grocery"
        numberOfDays = 30
        expiryDate = Date()
    }
    
}

struct EditProductView_Previews: PreviewProvider {
    static var previews: some View {
        EditProductView(product: Product(), numberOfDays: 30, productName: "",productType: "", expiryDate: Date())
    }
}
