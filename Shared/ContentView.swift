//
//  ContentView.swift
//  Shared
//
//  Created by saj panchal on 2021-09-19.
//

import SwiftUI
import CoreData
import CloudKit
import UserNotifications

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @FetchRequest(entity: Product.entity(), sortDescriptors: []) var products: FetchedResults<Product>
    
    var notification = CustomNotification()
    let productTypes = ["Document","Electronics","Grocery","Subscription", "Other"] 
    
    @State var productName: String = ""
    @State var productType = "Grocery"
    @State var expiryDate = Date().dayAfter
    @State var alertTitle = ""
    @State var alertImage = ""
    @State var alertMessage = ""
    @State var showCard = false
    @State var showAlert = false
    @State var isSignedIn = false
    @State var color: Color = .green
    @State var showTab = 0
    @State var showProductScanningView = false
    @State var showDateScanningView = false
    @State var viewTag = 0
    var body: some View {
        if !isSignedIn {
            LaunchScreen(isSignedIn: $isSignedIn)
            }
        else {
            TabView(selection: $showTab) {
                NavigationView {
                    ZStack {
                        VStack {
                            ProductForm( product: Product(),productName: $productName, productType: $productType, expiryDate: $expiryDate, showProductScanningView: $showProductScanningView, showDateScanningView: $showDateScanningView, alertTitle:$alertTitle, alertImage:$alertImage, alertMessage: $alertMessage, color:$color, showCard: $showCard, showAlert:$showAlert, viewTag: $viewTag)
                           
                        }
                        .navigationBarTitle("Add New Product")
                        
                        if showCard {
                            Card(title: alertTitle, image: alertImage, color: color)
                                .transition(.opacity)
                            let _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
                                withAnimation {
                                showCard = false
                                    if alertTitle == "Product Saved \n&\n All Done!" {
                                        showTab = 1
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear(perform: {
                    notification.notificationRequest()
                    updateProductsandNotifications()
                    printProducts()
                    notification.listOfPendingNotifications()
                })
                .onDisappear(perform: updateProductsandNotifications)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .sheet(isPresented: $showProductScanningView) {
                    ScanDocumentView(recognizedText: $productName)
                }
                .sheet(isPresented: $showDateScanningView) {
                    ScanDateView(recognizedText: $expiryDate)
                }
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
                
                ProductsListView()
                    .tabItem {
                        Image(systemName: "list.bullet.rectangle")
                        Text("List")
                    }
                    .tag(1)
                
                PreferencesView(showTab: $showTab)
                    .tabItem {
                        Image(systemName: "gearshape.2.fill")
                        Text("Preferences")
                    }
                    .tag(2)
            }
            .environmentObject(notification)
        }
    }
    
    func printProducts() {
        print("----------list of products in ContentView------------")
        for prod in products {
            print("\(prod.getProductID): ",prod.getName)
            print("exp date: \(prod.ExpiryDate)")
            print("red zone: \(prod.redZoneExpiry)")
            print("yellow zeon: \(prod.yellowZoneExpiry)")
         
        }
    }
    
    func updateProductsandNotifications() {
        for product in products {
            let result = notification.checkExpiry(expiryDate: product.expiryDate ?? Date().dayAfter, deleteAfter: product.DeleteAfter, product: product)
            notification.handleProducts(viewContext:viewContext, result: result, product: product)
      
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


extension Date {
    static var tomorrow: Date {
        return Date().dayAfter
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
}
