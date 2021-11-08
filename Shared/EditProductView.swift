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
    @State var alertTitle = "Edit Product"
    @State var alertImage = ""
    @State var alertMessage = ""
    @State var showCard = false
    @State var showAlert = false
    @State var color: Color = .green
    @State var showProductScanningView = false
    @State var showDateScanningView = false
    @State var viewTag = 1
    
    var body: some View {
        ZStack {
            VStack {
                ProductForm(product: product,productName: $productName, productType: $productType, expiryDate: $expiryDate, showProductScanningView: $showProductScanningView, showDateScanningView: $showDateScanningView, alertTitle:$alertTitle, alertImage:$alertImage, alertMessage: $alertMessage, color:$color, showCard: $showCard, showAlert:$showAlert, viewTag: $viewTag)
            }
            .navigationTitle("Edit Product")
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
            let result = Product.checkExpiry(expiryDate: product.expiryDate ?? Date().dayAfter, deleteAfter: product.DeleteAfter, product: product)
            Product.handleProducts(viewContext:viewContext, result: result, product: product, notification: notification)
        }
    }
    
    func printProducts() {
        print("----------list of products in EditProductView------------")
        for prod in products {
            print("\(prod.getProductID):",prod.getName)
        }
    }
}

struct EditProductView_Previews: PreviewProvider {
    static var previews: some View {
        EditProductView(product: Product(), productName: "",productType: "Grocery", expiryDate: Date().dayAfter)
    }
}
