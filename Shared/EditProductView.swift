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
    // show/hide this view
    @Environment(\.presentationMode) var presentationMode
    
    // cloudkit managed object context
    @Environment(\.managedObjectContext) var viewContext
    // cloudkit fetched records from Product entity.
    @FetchRequest(entity: Product.entity(), sortDescriptors: []) var products: FetchedResults<Product>
    //shared product record to be edited
    @ObservedObject var product: Product
    
    //shared notification object to manipulate product notifications
    let notification = CustomNotification()
    
    //variables to be manipulated in product form view.
    let productTypes = ["Document","Electronics","Grocery","Subscription", "Other"]
    @State var productName: String
    @State var productType: String
    @State var expiryDate: Date
    
    //variables to manipulate alert/card view texts and images.
    @State var alertTitle = "Edit Product"
    @State var alertImage = ""
    @State var alertMessage = ""
    
    //variables to show/hide cards/alerts.
    @State var showCard = false
    @State var showAlert = false
    
    //variable to set card bg color.
    @State var color: Color = .green
    
    //variables to show/hide cameraviews to scan product name or expiry date from images.
    @State var showProductScanningView = false
    @State var showDateScanningView = false
    @State var isDateNotFound: Int = 0
    //variable to determine which camera view to render.
    @State var viewTag = 1
    
    var body: some View {
        ZStack {
            //product form view
            VStack {
                ProductForm(product: product,productName: $productName, productType: $productType, expiryDate: $expiryDate, showProductScanningView: $showProductScanningView, showDateScanningView: $showDateScanningView, alertTitle:$alertTitle, alertImage:$alertImage, alertMessage: $alertMessage, color:$color, showCard: $showCard, showAlert:$showAlert, viewTag: $viewTag)
            }
            .navigationTitle("Edit Product")
            .onAppear(perform: printProducts)
            .onDisappear(perform: {
                presentationMode.wrappedValue.dismiss()
            })
            //pop up the camera view to scan and diplay product name
            .sheet(isPresented: $showProductScanningView) {
                ScanDocumentView(recognizedText: $productName)
                    .onDisappear(perform: {
                        if productName == "error" {
                            productName = ""
                            alertTitle = "Couldn't scan the product name!\n"
                            alertMessage = "--Possible Reasons--\n\n(1) Bad Image Scan - Make sure you take a snapshot with clear and bright view.\n\n(2) Inaccurate snippet - Make sure you are snipping the valid texts. Product Name snippet must be showing the product's name in clear and full view.\n\n(3) Bad Text - text printed on a product is bad to scan it accurately!\n"
                            showAlert = true
                        }
                        else {
                            alertTitle = "Product Name Scan Successful!"
                            alertImage = "checkmark.seal.fill"
                            color = .green
                            showCard = true
                        }
                    })
            }
            //pop up the camera view to scan and diplay product expiry
            .sheet(isPresented: $showDateScanningView) {
                ScanDateView(recognizedText: $expiryDate, isDateNotFound: $isDateNotFound)
                    .onDisappear(perform: {
                        if isDateNotFound == 2 {
                            alertTitle = "Couldn't scan the expiry date!\n"
                            alertMessage = "--Possible Reasons--\n\n(1) Bad Image Scan - Make sure you take a snapshot with clear and bright view.\n\n(2) Inaccurate snippet - Make sure you are snipping only the expiry date text only! Expiry date snippet must be showing the date in clear and full view.\n\n(3) Bad Text - Exiry date printed on a product bad to scan the date accurately!\n\n(4) Unsupported Date Format - Date format of the product exipry may not be supported by our app."
                            showAlert = true
                        }
                        else if isDateNotFound == 1 {
                            alertTitle = "Expiry Date Scan Successful!"
                            alertImage = "checkmark.seal.fill"
                            color = .green
                            showCard = true
                        }
                    })
            }
            //show the card if this variable is true
            if showCard {
                Card(title: alertTitle, image: alertImage, color: color)
                //with animation change card view opacity
                    .transition(.opacity)
                //after 3 seconds hide the card with animation.
                let _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
                    withAnimation {
                        showCard = false
                        //dismiss the edit product view.
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    //same as in content view.
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
