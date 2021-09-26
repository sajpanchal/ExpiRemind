//
//  ContentView.swift
//  Shared
//
//  Created by saj panchal on 2021-09-19.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Product.entity(), sortDescriptors: []) var products: FetchedResults<Product>
    let productTypes = ["Document","Electronics","Grocery","Subscription", "Other"]
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
                    }
                }
                .navigationBarItems(leading:Button("Discard") {
                    productName = ""
                    expiryDate = Date()
                    productType = "Grocery"
                    alertTitle = "Discarded!"
                    alertMessage = "New Product has been discarded successfully."
                    showAlert = true
                }
                .foregroundColor(.red), trailing: Button("Done") {
                    if productName.count >= 2 {
                        addProduct()
                        alertTitle = "Saved!"
                        alertMessage = "New Product has been saved successfully."
                        showAlert = true
                    }
                    else {
                        alertTitle = "Something went wrong!"
                        alertMessage = "Please enter the product name with atleast 2 characters length. Make sure to set its type and expiry date too!"
                        showAlert = true
                    }
                })
                .navigationBarTitle("Add New Product")
            }
            .onAppear(perform: {
                for product in products {
                    print(product.getName)
                    if checkExpiry(expiryDate: product.expiryDate ?? Date(), deleteDays: product.DeleteAfter) {
                        product.type = "Subscription"
                        do {
                            try viewContext.save()
                        }
                        catch {
                            fatalError(error.localizedDescription)
                        }
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
    func checkExpiry(expiryDate: Date, deleteDays: Int) -> Bool {
        if expiryDate > Date() {
            let diff = Calendar.current.dateComponents([.day], from: expiryDate, to: Date())
            print("difference is: ",diff)
            return false
        }
        else {
            let diff = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate)
            if let days = diff.day {
                if days >= deleteDays {
                    return true
                }
                else {
                    return false
                }
            }
            
        }
        return false
    }
    func addProduct() {
        let product = Product(context: viewContext)
        product.name = productName
        product.type = productType
        product.expiryDate = expiryDate
        product.dateStamp = Date()
        
        do {
            try viewContext.save()
            print("product saved")
            for product in products {
                print(product)
            }
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
