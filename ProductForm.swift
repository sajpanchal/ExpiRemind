//
//  ProductForm.swift
//  NotifyExpiryDate (iOS)
//
//  Created by saj panchal on 2021-10-26.
//

import SwiftUI

struct ProductForm: View {
    let productTypes = ["Document","Electronics","Grocery","Subscription", "Other"]
    @Binding var productName: String
    @Binding var productType: String
    @Binding var expiryDate: Date
    @Binding var showScanningView: Bool
    var body: some View {
        Form {
            Section(header: Text("Product Name")) {
                HStack {
                    TextField("Enter Product Name", text:$productName)
                    Spacer()
                    Image(systemName: "camera.viewfinder")
                        .onTapGesture {
                            showScanningView = true
                        }
                }
            }
            Section(header: Text("Product Type")) {
                Picker("Select Product Type", selection: $productType) {
                    ForEach(productTypes, id: \.self) {
                        Text($0)
                    }
                }
            }
            Section(header: Text("Expiry Date")) {
                DatePicker(selection: $expiryDate, in: Date().dayAfter..., displayedComponents: .date) {
                    Text("Set Expiry Date")
                }
            }
        }
    }
}

struct ProductForm_Previews: PreviewProvider {
    static var previews: some View {
        ProductForm(productName: .constant(""), productType: .constant(""), expiryDate: .constant(Date().dayAfter), showScanningView: .constant(false))
    }
}
