//
//  EditProductView.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-09-24.
//

import SwiftUI

struct EditProductView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: Product.entity(), sortDescriptors: []) var products: FetchedResults<Product>
    @State var product: Product
    let productTypes = ["Document","Electronics","Grocery","Subscription", "Other"]
    @State var productName: String = ""
    @State var productType = "Grocery"
    @State var expiryDate = Date()
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
                saveChanges()
            }
        }
        .navigationTitle("Edit Product")
        .onAppear(perform: {
            fetchProduct()
        })
    }
    func fetchProduct() {
        productName = product.getName
        productType = product.getType
        expiryDate = product.expiryDate!
        print("Product fetched...")
        print("product name:",(product.getName))
        print("product type:",(product.getType))
        print("product expiry:",(product.ExpiryDate))
    }
    func saveChanges() {
        if let prod = products.first(where: {$0.CreatedAt == product.CreatedAt}) {
            prod.name = productName
            prod.type = productType
            prod.expiryDate = expiryDate
            prod.createdAt = Date()
            
            do {
                try viewContext.save()
                print("Product saved...")
                print("product name:",(prod.getName))
                print("product type:",(prod.getType))
                print("product expiry:",(prod.ExpiryDate))
            }
            catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}

struct EditProductView_Previews: PreviewProvider {
    static var previews: some View {
        EditProductView( product: Product())
    }
}
