//
//  ListRowView.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-09-21.
//

import SwiftUI

struct ListRowView: View {
    @EnvironmentObject var notification: CustomNotification
    @ObservedObject var product: Product
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(product.getName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .frame(alignment: .leading)
                Spacer()
                VStack {
                    Text("Expiry Date")
                        .foregroundColor(.primary)
                        .font(.caption)
                    Text(isExpired(expiryDate: product.expiryDate ?? Date().dayAfter) ? product.ExpiryDate: product.ExpiryDate)
                        .fontWeight(.bold)
                        .font(.body)
                        .foregroundColor(setForgroundColor())
                        
                }
                .frame(alignment: .trailing)
            }
            Spacer()
            HStack {
                Text(product.DateStamp)
                    .foregroundColor(.secondary)
                    .font(.system(size: 10))
            }
            .frame(alignment: .trailing)
        }.foregroundColor(isExpired(expiryDate: product.expiryDate ?? Date().dayAfter) ? .red : .clear)
    }
    func isExpired(expiryDate: Date) -> Bool {
       let result = Calendar.current.compare((Date()), to: expiryDate, toGranularity: .day)
        switch result {
        case .orderedDescending :
            return true
        case .orderedAscending :
            return false
        case .orderedSame :
            return false
        }
       
    }
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
