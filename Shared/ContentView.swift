//
//  ContentView.swift
//  Shared
//
//  Created by saj panchal on 2021-09-19.
//

import SwiftUI
import CoreData
import UserNotifications
import AuthenticationServices
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
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
    var body: some View {
        if !isSignedIn {
            VStack {
                Spacer()
                Image("appstore")
                    .resizable()
                    .frame(width: 250, height: 250, alignment: .center)
                    .cornerRadius(10.0)
                Text("ExpiRemind")
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundColor(Color(red: 0.832, green: 0.316, blue: 0.16, opacity: 1))
                Spacer()
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success:
                        isSignedIn = true
                    case .failure(let error):
                        isSignedIn = false
                        print(error.localizedDescription)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
                .padding()
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                
            }
            }
        else {
            TabView(selection: $showTab) {
                NavigationView {
                    ZStack {
                        
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
                                    DatePicker(selection: $expiryDate, in: Date().dayAfter..., displayedComponents: .date) {
                                        Text("Set Expiry Date")
                                    }
                                }
                            }
                        }
                        .navigationBarItems(leading:HStack { Button("Discard") {
                            productName = ""
                            expiryDate = Date().dayAfter
                            productType = "Grocery"
                            alertTitle = "Product Discarded!"
                            alertImage = "xmark.seal.fill"
                            color = .red
                            withAnimation {
                            
                                self.showCard = true
                                
                             
                            }
                                                   
                        }
                        .disabled(productName.isEmpty)
                        .foregroundColor(.red)
                   
                        }
                                            , trailing: HStack { Button("Done") {
                            if productName.count >= 2 {
                                addProduct()
                                alertTitle = "Product Saved!"
                                alertImage = "checkmark.seal.fill"
                                color = .green
                                withAnimation {
                                
                                    self.showCard = true
                                    
                                 
                                }
                            }
                            else {
                                alertTitle =  "Something went wrong!"
                            alertMessage = "Please enter the product name with atleast 2 characters length. Make sure to set its type and expiry date too!"
                                showAlert = true
                            }
                        }
                        .disabled(productName.isEmpty)
                            
                        }
                            )
                        .navigationBarTitle("Add New Product")
                        if showCard {
                            Card(title: alertTitle, image: alertImage, color: color)
                                .transition(.opacity)
                            let timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
                                withAnimation {
                                showCard = false
                                    if color == .green {
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
                })
                .onDisappear(perform: updateProductsandNotifications)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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
    func showAppleLoginView() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.performRequests()
    }
    func updateProductsandNotifications() {
        for product in products {
            let result = notification.checkExpiry(expiryDate: product.expiryDate ?? Date().dayAfter, deleteAfter: product.DeleteAfter, product: product)
            notification.handleProducts(viewContext:viewContext, result: result, product: product)
            notification.saveContext(viewContext: viewContext)
        }
    }
    
   
    func addProduct() {
        let product = Product(context: viewContext)
        product.name = productName
        product.type = productType
        print("-------------addProduct()---------------")
        print("expiryDate:",expiryDate)
        product.expiryDate = modifyDate(date: expiryDate)
        product.dateStamp = Date()
        
        product.deleteAfter = Int16( UserDefaults.standard.integer(forKey: "numberOfDays") == 0 ? 1 : UserDefaults.standard.integer(forKey: "numberOfDays"))
        notification.saveContext(viewContext: viewContext)
        productName = ""
        expiryDate = Date().dayAfter
        notification.notificationRequest()
        notification.sendTimeNotification(product: product)
    }
    func modifyDate(date: Date) -> Date {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let dateStr = formatter.string(from: date)
        let modifiedDateStr = "\(dateStr), 8:30 AM"
        formatter.timeStyle = .short
        let modifiedDate = formatter.date(from: modifiedDateStr)
        print("modified date:\(String(describing: modifiedDate))")
        return modifiedDate ?? date
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
