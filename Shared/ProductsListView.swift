//
//  ProductsListView.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-09-21.
//

import SwiftUI
import CoreData
import CloudKit

struct ProductsListView: View {

    //cloudKit view context
    @Environment(\.managedObjectContext) var viewContext
    //fetched records from cloudkit product entity.
    @FetchRequest(entity: Product.entity(), sortDescriptors: ProductsSort.default.descriptors) var products: FetchedResults<Product>
  @State var selectedSort = ProductsSort.default
    //shared object for notification handling.
    @EnvironmentObject var notification: CustomNotification
    
    //array to divide products in sections based on product types.
    let productTypes = ["Document","Electronics","Grocery","Subscription", "Other"]
  
    //to show edit product view.
  //  @State var showEditProductView = false
    
    var body: some View {
        NavigationView {
            VStack {
                // list view to show added products in list format.
                List {
                    // create sections based on product types.
                    ForEach(productTypes, id: \.self) { type in
                        // in each section render the list of products of that type only.
                        Section(header: Text(type).foregroundColor(.secondary)) {
                            ForEach(products, id: \.self) { product in
                                // if the type is matched
                                if product.getType == type {
                                    // display that product with a link to edit product view.
                                    NavigationLink(
                                        destination: EditProductView(index: products.firstIndex(of: product)!,product: product, productName: product.getName, productType: product.getType, expiryDate: product.expiryDate ?? Date().dayAfter),
                                        // navigation link appearance.
                                        label: {
                                            ZStack {
                                               
                                                    //view that creates a UI for each list row.
                                                    ListRowView(index: products.firstIndex(of: product)!,product: product)
                                                
                                               
                                                
                                                //if product is expired.
                                                if isExpired(expiryDate: product.expiryDate!) {
                                                    //show the text in watermark format.
                                                    Text("Expired")
                                                        .font(.largeTitle)
                                                        .fontWeight(.black)
                                                        .foregroundColor(Color(red: 1.0, green: 0, blue: 0, opacity: 1))
                                                        //.padding()
                                                        .background(Color.primary)
                                                        .cornerRadius(5.0)
                                                }
                                            }
                                        })
                                        //disable the navigation link if product is expired.
                                        .disabled(isExpired(expiryDate: product.expiryDate!))
                                }
                            }
                            // delete the product on swipe and delete.
                            .onDelete(perform: deleteProduct)
                        }
                    }
                }
            }
          
            .navigationBarItems(trailing: SortSelectionView(selectedSortItem: $selectedSort, sorts: ProductsSort.sorts).onChange(of: selectedSort) {_ in
                    if #available(iOS 15.0, *) {
                        products.nsSortDescriptors = selectedSort.descriptors
                    } else {
                        // Fallback on earlier versions
                    }
                }
            )
            .onAppear(perform: {
              
                print("-------------Product list--------------")
                for prod in products {
                    
                    
                    print("\(prod.getProductID): ",prod.getName)
                    print("isNotificationSet: ", prod.isNotificationSet)
                }
               // notification.notificationRequest()
                //updateProductsandNotifications()
            })
            .navigationTitle(Text("List of Products"))
           
            
        }
        
    }
    
    func updateProductsandNotifications() {
        for product in products {
            let result = Product.checkExpiry(expiryDate: product.expiryDate ?? Date().dayAfter, deleteAfter: product.DeleteAfter, product: product)
            Product.handleProducts(viewContext:viewContext, result: result, product: product, notification:notification)
            
        }
    }
    //check if the product expiry is gone, yet to come or is there.
    func isExpired(expiryDate: Date) -> Bool {
       let result = Calendar.current.compare(Date(), to: expiryDate, toGranularity: .day)
        switch result {
        case .orderedDescending :
            return true
        case .orderedAscending :
            return false
        case .orderedSame :
            return true
        }
    }
    // delete the given product from list of products by indexSet
    func deleteProduct(at offsets: IndexSet) {
        print("offsets", offsets)
        //get the offset from Index set.
        for offset in offsets {
            // it will get the product index with a delete action.
            print("offset is:", offset)
            let product = products[offset]
            print("product is :\(product.getName)")
            
            //remove the notification trigger request of deleted product.
            notification.removeNotification(product: product)
            
            //delete the product from context.
            viewContext.delete(product)
        }
        // save the managed object context.
        Product.saveContext(viewContext: viewContext)
    }
}

struct ProductsListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsListView()
    }
}
