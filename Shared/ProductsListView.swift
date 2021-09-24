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
                                        destination: EditProductView(product: product, productName: product.getName, productType: product.getType, expiryDate: product.expiryDate!),
                                        label: {
                                            ListRowView(product: product)
                                        })
                                    
                                }
                            }
                        }
                    }
                }                                                
            }
            .onAppear(perform: {
               ProductsListView()
                print("products list view is updated.")
            })
            .sheet(isPresented: $showEditProductView) {
                EditProductView(product: products.first!, productName: "", productType: "", expiryDate: Date())
            }
            .navigationTitle("List of Products")
        }
    }
}

struct ProductsListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsListView()
    }
}
