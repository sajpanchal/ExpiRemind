//
//  ProductsListView.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-09-21.
//

import SwiftUI

struct ProductsListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: Product.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Product.expiryDate, ascending: true)]) var products: FetchedResults<Product>
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Document")) {
                        ForEach(products, id: \.self) { product in
                            if product.getType == "Document" {
                                ListRowView(product: product)
                            }
                        }
                    }
                    Section(header: Text("Electronics")) {
                        ForEach(products, id: \.self) { product in
                            if product.getType == "Electronics" {
                                ListRowView(product: product)
                            }
                        }
                        
                    }
                    Section(header: Text("Grocery")) {
                        ForEach(products, id: \.self) { product in
                            if product.getType == "Grocery" {
                                ListRowView(product: product)
                            }
                        }
                    }
                    Section(header: Text("Subscripition")) {
                        ForEach(products, id: \.self) { product in
                            if product.getType == "Subscripition" {
                                ListRowView(product: product)
                            }
                        }
                    }
                    Section(header: Text("Other")) {
                        ForEach(products, id: \.self) { product in
                            if product.getType == "Other" {
                                ListRowView(product: product)
                            }
                        }
                    }
                }                                                
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
