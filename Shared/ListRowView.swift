//
//  ListRowView.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-09-21.
//

import SwiftUI

struct ListRowView: View {
    @State var product: Product
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(product.getName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                Spacer()
                VStack {
                    Text("Expiry Date")
                        .foregroundColor(.primary)
                        .font(.caption)
                     Text(product.ExpiryDate)
                        .fontWeight(.bold)
                        .font(.body)
                        .foregroundColor(.red)
                }
                .frame(alignment: .trailing)
            }
            Spacer()
            HStack {
                Text(product.CreatedAt)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    
            }
        }
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowView(product: Product())
    }
}
