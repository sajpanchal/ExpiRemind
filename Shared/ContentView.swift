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
    //cloudKit view context
    @Environment(\.managedObjectContext) private var viewContext
    
    //fetched records from cloudkit entity 'Product'
    @FetchRequest(entity: Product.entity(), sortDescriptors: []) var products: FetchedResults<Product>
    
    //custom notification object to handle notifications and product
    var notification = CustomNotification()

    //to show/hide launch screen.
    @State var isSignedIn = false
    
    //variables used in product form
    let productTypes = ["Document","Electronics","Grocery","Subscription", "Other"]
    @State var productName: String = ""
    @State var productType = "Grocery"
    @State var expiryDate = Date().dayAfter
    
    //variables to create alerts and cards.
    @State var alertTitle = ""
    @State var alertImage = ""
    @State var alertMessage = ""
    @State var showCard = false
    @State var showAlert = false
    @State var color: Color = .green
    
    //variable to render tab view.
    @State var showTab = 0
    
    //variables to render Camera view to scan text from images.
    @State var showProductScanningView = false
    @State var showDateScanningView = false
    
    //variable used in product form to determine whether to show form to create product or edit product.
    @State var viewTag = 0
    
    var body: some View {
        // if user is not signed in show launch screen.
        if !isSignedIn {
            LaunchScreen(isSignedIn: $isSignedIn)
            }
        // if user is signed in show the tab view.
        else {
            TabView(selection: $showTab) {
                // navigation view with product form.
                NavigationView {
                    ZStack {
                        VStack {
                            //product form
                            ProductForm( product: Product(),productName: $productName, productType: $productType, expiryDate: $expiryDate, showProductScanningView: $showProductScanningView, showDateScanningView: $showDateScanningView, alertTitle:$alertTitle, alertImage:$alertImage, alertMessage: $alertMessage, color:$color, showCard: $showCard, showAlert:$showAlert, viewTag: $viewTag)
                        }
                        .navigationBarTitle("Add New Product")
                        
                        // if card is rendered by user actions.
                        if showCard {
                            // render the card view.
                            Card(title: alertTitle, image: alertImage, color: color)
                                .transition(.opacity)
                            // timer with delay of 3 seconds to hide the card after 3 seconds.
                            let _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
                                // hide the card with animation.
                                withAnimation {
                                showCard = false
                                    // if card is having this title
                                    if alertTitle == "Product Saved \n&\n All Done!" {
                                        //show the list of products tab view right away.
                                        showTab = 1
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear(perform: {
                    //method to
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
            print("\(prod.getProductID):", prod.getName)
            print("exp date: \(prod.ExpiryDate)")
            print("red zone: \(prod.redZoneExpiry)")
            print("yellow zeon: \(prod.yellowZoneExpiry)")
         
        }
    }
    
    func updateProductsandNotifications() {
        for product in products {
            let result = Product.checkExpiry(expiryDate: product.expiryDate ?? Date().dayAfter, deleteAfter: product.DeleteAfter, product: product)
            Product.handleProducts(viewContext:viewContext, result: result, product: product, notification: notification)
      
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
