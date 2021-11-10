//
//  ListRowView.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-09-21.
//

import SwiftUI

struct ListRowView: View {
    //shared notification object
    @EnvironmentObject var notification: CustomNotification
    
    //shared product object
    @ObservedObject var product: Product
    var body: some View {
        VStack {
            HStack {
                VStack {
                    //display product name
                    Text(product.getName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .frame(alignment: .leading)
                
                Spacer()
                
                //display expiry date
                VStack {
                    Text("Expiry Date")
                        .foregroundColor(.primary)
                        .font(.caption)
                    
                    Text(product.ExpiryDate)
                        .fontWeight(.bold)
                        .font(.body)
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
    
    /*func isExpired(expiryDate: Date) -> Bool {
       let result = Calendar.current.compare((Date()), to: expiryDate, toGranularity: .day)
        switch result {
        case .orderedDescending :
            return true
        case .orderedAscending :
            return false
        case .orderedSame :
            return false
        }
       
    }*/
    func setForgroundColor() -> Color {
        let result = Product.checkExpiry(expiryDate: product.expiryDate ?? Date(), deleteAfter: product.DeleteAfter, product: product)
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
        ListRowView(product: Product())
    }
}
