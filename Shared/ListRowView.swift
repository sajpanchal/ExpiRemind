//
//  ListRowView.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-09-21.
//

import SwiftUI

struct ListRowView: View {
    //fetched records from cloudkit product entity.
    @FetchRequest(entity: Product.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Product.expiryDate, ascending: true)]) var products: FetchedResults<Product>
    @Environment(\.managedObjectContext) var viewContext
    //shared notification object
    @EnvironmentObject var notification: CustomNotification
    var index: Int
    @State var color: Color = .yellow
    @State var imageName = "bell.fill"
    @State var sendAlert = false
    //shared product object
    @ObservedObject var product: Product
    var body: some View {
        HStack {
            VStack {
                Image(systemName: imageName)
                    .foregroundColor(color)
                    .onTapGesture {
                        if color == .red && Product.checkNumberOfReminders(products: products) < 20 {
                            product.isNotificationSet = true
                            Product.saveContext(viewContext: viewContext)
                            color = .yellow
                            imageName = "bell.fill"
                            notification.sendTimeNotification(product: product)
                            
                        }
                        else if color == .yellow {
                            product.isNotificationSet = false
                            Product.saveContext(viewContext: viewContext)
                            notification.removeNotification(product: product)
                            color = .red
                            imageName = "bell.slash.fill"
                        }
                        else {
                            sendAlert = true
                        }
                        
                    }
                Spacer()
            }
            Spacer()
            VStack {
                
                HStack {
                    
                    VStack {
                        
                        //display product name
                        Text(product.getName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .frame(alignment: .leading)
                    
                    Spacer()
                    
                    //display expiry date
                    VStack {
                        Text("Expiry Date")
                            .foregroundColor(.primary)
                            .font(.caption2)
                        
                        Text(product.ExpiryDate)
                            .fontWeight(.bold)
                            .font(.caption)
                            //set forground color of the expiry date based on expiry date zone.
                            .foregroundColor(setForgroundColor())
                            
                    }
                    .frame(alignment: .trailing)
                }
                
                Spacer()
                //display date stamp of last updates.
                HStack {
                    Text(product.DateStamp)
                        .foregroundColor(.secondary)
                        .font(.system(size: 10))
                }
                .frame(alignment: .trailing)
            }
        }
        .alert(isPresented: $sendAlert) {
            Alert(title: Text("Can't set notifications for this product\n"), message: Text("You can only set notifications for 20 products at a time. \nTo set notification for this product disable notifications for other products that are less relevant to you."), dismissButton: .default(Text("OK")))
         }
        .onAppear(perform: {
            if product.isNotificationSet {
                color = .yellow
                imageName = "bell.fill"
            }
            else {
                color = .red
                imageName = "bell.slash.fill"
            }
        })
       
    }
        
    /*func checkNumberOfReminders() -> Int {
        var counter = 0
        for prod in products {
            if prod.isNotificationSet == true {
                counter += 1
            }
        }
        return counter
    }*/
    //set forground color of expiry date text
    func setForgroundColor() -> Color {
        // check the status of expiry date
        let result = Product.checkExpiry(expiryDate: product.expiryDate ?? Date(), deleteAfter: product.DeleteAfter, product: product)
        // return the color based on result.
        switch result {
        case "Alive":
            return Color.green
        case "Far From Expiry":
            return Color.yellow
        case "Near Expiry":
            return Color.red
        case "Expired":
            return Color.red
        default:
            return Color.green
        }
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowView( index: 0,product: Product())
    }
}
