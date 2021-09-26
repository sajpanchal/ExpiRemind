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
                saveChanges()
                presentationMode.wrappedValue.dismiss()
            }
            Spacer()
        }
        .navigationTitle("Edit Product")
        .navigationBarItems(trailing: Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                                .onTapGesture(perform: deleteProduct))
        .onAppear(perform: {
            fetchProduct()
        })
        .onDisappear(perform: {
            presentationMode.wrappedValue.dismiss()
        })
        
    }
    func fetchProduct() {
        productName = product.getName
        productType = product.getType
        expiryDate = product.expiryDate ?? Date()
    }
    func saveChanges() {
        if let prod = products.first(where: {$0.CreatedAt == product.CreatedAt})  {
            prod.name = productName
            prod.type = productType
            prod.expiryDate = expiryDate
            prod.createdAt = Date()
            do {
                try viewContext.save()
            }
            catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    func deleteProduct() {
        viewContext.delete(product)
        do {
            try viewContext.save()
        }
        catch {
            fatalError(error.localizedDescription)
        }
        productName = ""
        productType = "Grocery"
        expiryDate = Date()
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditProductView_Previews: PreviewProvider {
    static var previews: some View {
        EditProductView( product: Product(), productName: "",productType: "", expiryDate: Date())
    }
}
