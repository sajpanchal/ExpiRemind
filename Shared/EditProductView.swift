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
    let daysCollection = [1, 3, 7, 30]
    @State var numberOfDays: Int
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
                Section(header: Text("Delete after number of days expiry")) {
                    Picker("Select the number of days", selection: $numberOfDays) {
                        ForEach(daysCollection, id: \.self) {
                            Text("\($0) Days")
                        }
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
        .onDisappear(perform: {
            presentationMode.wrappedValue.dismiss()
        })
        
    }
    
    func saveChanges() {
        if let prod = products.first(where: {$0.DateStamp == product.DateStamp})  {
            prod.name = productName
            prod.type = productType
            prod.expiryDate = expiryDate
            prod.dateStamp = Date()
            prod.deleteAfter = Int16(numberOfDays)
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
        numberOfDays = 30
        expiryDate = Date()
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditProductView_Previews: PreviewProvider {
    static var previews: some View {
        EditProductView(product: Product(), numberOfDays: 30, productName: "",productType: "", expiryDate: Date())
    }
}
