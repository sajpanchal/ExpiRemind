//
//  ProductsListView.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-09-21.
//

import SwiftUI
import CoreData
struct ProductsListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: Product.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Product.expiryDate, ascending: true)]) var products: FetchedResults<Product>
    let productTypes = ["Document","Electronics","Grocery","Subscription", "Other"]
    var notification = CustomNotification()
    @State var showEditProductView = false
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(productTypes, id: \.self) { type in
                        Section(header: Text(type)) {
                            ForEach(products, id: \.self) { product in
                               
                                if product.getType == type {
                                    NavigationLink(
                                        destination: EditProductView(product: product, numberOfDays: product.DeleteAfter, productName: product.getName, productType: product.getType, expiryDate: product.expiryDate ?? Date()),
                                        label: {
                                          
                                                ListRowView(product: product)
                                                
                                           
                                        })
                                        //.listRowBackground(isExpired(expiryDate: product.expiryDate!) ? Color.init(red: 195.0, green: 0.0, blue: 0.0) : Color.clear)
                                        .disabled(isExpired(expiryDate: product.expiryDate!))
                                }
                                  
                            }
                           
                            .onDelete(perform: deleteProduct)
                            
                        }
                    }
                   
                }
               
                
            }
            .navigationTitle("List of Products")
        }
    }
    func isExpired(expiryDate: Date) -> Bool {
       let result = Calendar.current.compare(Date(), to: expiryDate, toGranularity: .day)
        switch result {
        case .orderedDescending :
            return true
        case .orderedAscending :
            return false
        case .orderedSame :
            return false
        }
       
    }
    func deleteProduct(at offsets: IndexSet) {
        for offset in offsets {
            let product = products[offset]
            notification.removeNotification(product: product)
            viewContext.delete(product)
        }
        do {
            try viewContext.save()
            print("product deleted...")
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
}

struct ProductsListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsListView()
    }
}
