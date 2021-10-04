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
    @EnvironmentObject var notification: CustomNotification
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
                                            ZStack {
                                                ListRowView(product: product)
                                                if isExpired(expiryDate: product.expiryDate ?? Date()) {
                                                    Text("Expired")
                                                        .font(.largeTitle)
                                                        .foregroundColor(.gray)
                                                        
                                                }
                                            }
                                        })
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
        notification.saveContext(viewContext: viewContext)
        notification.removeAllNotifications()
        notification.notificationRequest()
        
        for product in products {
            let result = notification.checkExpiry(expiryDate: product.expiryDate ?? Date(), deleteAfter: product.DeleteAfter, product: product)
            notification.handleProducts(viewContext:viewContext, result: result, product: product)
            notification.saveContext(viewContext: viewContext)
        }
    }
}


struct ProductsListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsListView()
    }
}
