//
//  EditProductView.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-09-24.
//

import SwiftUI
import CoreData
import CloudKit

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
    @State var alertTitle = ""
    @State var alertImage = ""
    @State var alertMessage = ""
    @State var showCard = false
    @State var showAlert = false
    @State var color: Color = .green
    @State var showProductScanningView = false
    @State var showDateScanningView = false
    var body: some View {
        ZStack {
            VStack {
                ProductForm(productName: $productName, productType: $productType, expiryDate: $expiryDate, showProductScanningView: $showProductScanningView, showDateScanningView: $showDateScanningView, alertTitle:$alertTitle, alertImage:$alertImage, alertMessage: $alertMessage, color:$color, showCard: $showCard, showAlert:$showAlert)
                Button("Save Changes") {
                    // save the product changes, remove notification of old changes.
                  //  notification.notificationRequest()
                    
                  //  updateProductsandNotifications()
                    alertTitle = "Saved Changes!"
                    alertImage = "checkmark.seal.fill"
                    color = .green
                    
                    saveChanges()
                   
                   
                    withAnimation {
                        showCard = true
                    }
                   // presentationMode.wrappedValue.dismiss()
                }
                Spacer()
            }
            .navigationTitle("Edit Product")
            .navigationBarItems(trailing: Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                                    .onTapGesture(perform: {
                alertTitle = "Product Discarded!"
                alertImage = "xmark.seal.fill"
                color = .red
                deleteProduct()
                withAnimation {
                
                    self.showCard = true
                    
                 
                }
               
                
            }
                                                 ))
            .onAppear(perform: printProducts)
            .onDisappear(perform: {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showProductScanningView) {
                ScanDocumentView(recognizedText: $productName)
            }
            .sheet(isPresented: $showDateScanningView) {
                ScanDateView(recognizedText: $expiryDate)
            }
            if showCard {
                Card(title: alertTitle, image: alertImage, color: color)
                    .transition(.opacity)
                let _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
                    withAnimation {
                    showCard = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
         
    }
    func updateProductsandNotifications() {
        for product in products {
            let result = notification.checkExpiry(expiryDate: product.expiryDate ?? Date().dayAfter, deleteAfter: product.DeleteAfter, product: product)
            notification.handleProducts(viewContext:viewContext, result: result, product: product)
          
        }
    }
    func printProducts() {
        print("----------list of products in EditProductView------------")
        for prod in products {
            print("\(prod.getProductID):",prod.getName)
        }
    }
    func saveChanges() {
        if let prod = products.first(where: {$0.DateStamp == product.DateStamp})  {
            print("------------Saving changes for \(prod.getName)------------")
            
            notification.removeNotification(product: product)
            
            prod.name = productName
            prod.type = productType
            prod.expiryDate = expiryDate
            prod.dateStamp = Date()
            
            notification.saveContext(viewContext: viewContext)
            notification.sendTimeNotification(product: product)
            
            // dismiss the view.
        
        }
    }
    
    func deleteProduct() {
        notification.removeNotification(product: product)       
        
        viewContext.delete(product)
        notification.saveContext(viewContext: viewContext)
        
        DispatchQueue.main.async {
            resetFormInputs()
        }
       
    }
    
    func resetFormInputs() {
        productName = ""
        productType = "Grocery"
        expiryDate = Date().dayAfter
    }
    
}

struct EditProductView_Previews: PreviewProvider {
    static var previews: some View {
        EditProductView(product: Product(), productName: "",productType: "Grocery", expiryDate: Date().dayAfter)
    }
}
