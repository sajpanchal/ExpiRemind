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
    let notification = CustomNotification()
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
            }
            Button("Save Changes") {
                // save the product changes, remove notification of old changes.
                saveChanges()
                notification.removeAllNotifications()
                notification.notificationRequest()
                
                updateProductsandNotifications()
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
    func updateProductsandNotifications() {
        for product in products {
            let result = notification.checkExpiry(expiryDate: product.expiryDate ?? Date(), deleteAfter: product.DeleteAfter, product: product)
            notification.handleProducts(viewContext:viewContext, result: result, product: product)
            notification.saveContext(viewContext: viewContext)
        }
    }
    
    func saveChanges() {
        if let prod = products.first(where: {$0.DateStamp == product.DateStamp})  {
            notification.removeNotification(product: product)
            prod.name = productName
            prod.type = productType
            prod.expiryDate = expiryDate
            prod.dateStamp = Date()
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
        expiryDate = Date()
    }
    
}

struct EditProductView_Previews: PreviewProvider {
    static var previews: some View {
        EditProductView(product: Product(), productName: "",productType: "", expiryDate: Date())
    }
}
