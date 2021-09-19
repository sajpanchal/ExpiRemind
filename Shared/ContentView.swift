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
    let productTypes = ["Document","Electronics","Grocery","Subscripition", "Other"]
    @State var productName: String = ""
    @State var productType = "Grocery"
    @State var expiryDate = Date()
    
    var body: some View {
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
            }
            .foregroundColor(.red), trailing: Button("Done") {
                
            })
            .navigationBarTitle("Add New Product")
                
        }
        
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
