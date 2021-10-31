//
//  ProductForm.swift
//  NotifyExpiryDate (iOS)
//
//  Created by saj panchal on 2021-10-26.
//

import SwiftUI

struct ProductForm: View {
    @FetchRequest(entity: Product.entity(), sortDescriptors: []) var products: FetchedResults<Product>
    let productTypes = ["Document","Electronics","Grocery","Subscription", "Other"]
    @ObservedObject var product: Product
    @Binding var productName: String
    @Binding var productType: String
    @Binding var expiryDate: Date
    @Binding var showProductScanningView: Bool
    @Binding var showDateScanningView: Bool
    @Binding var alertTitle: String
    @Binding var alertImage: String
    @Binding var alertMessage: String
    @Environment(\.managedObjectContext) var viewContext
    @Binding var color: Color
    @Binding var showCard: Bool
    @Binding var showAlert: Bool
    @Binding var viewTag: Int
    @EnvironmentObject var notification: CustomNotification
    var body: some View {
        Form {
            Section(header: Text("Product Name")) {
                HStack {
                    TextField("Enter Product Name", text:$productName)
                    Spacer()
                    Image(systemName: "camera.viewfinder")
                        .onTapGesture {
                            showProductScanningView = true
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
                HStack {
                    DatePicker(selection: $expiryDate, in: Date().dayAfter..., displayedComponents: .date) {
                        Text("Set Expiry Date")
                        
                    }
                    .datePickerStyle(.compact)
                    .accentColor(.secondary)
                    
                    Spacer()
                    Image(systemName: "camera.viewfinder")
                        .onTapGesture {
                            showDateScanningView = true
                        }
                }
                
            }
            if viewTag == 1 {
                VStack {                  
                    Button {
                        alertTitle = "Saved Changes!"
                        alertImage = "checkmark.seal.fill"
                        color = .green
                        saveChanges()
                        withAnimation {
                            showCard = true
                        }
                    } label : {
                        HStack {
                            Spacer()
                            Text("Save")
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .frame(height: 50, alignment: .center)
                    }
                    .background(Color.gray)
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(10)
                    .padding(.bottom, 10)
                    
                    Button {
                        alertTitle = "Product Discarded!"
                        alertImage = "xmark.seal.fill"
                        color = .red
                        deleteProduct()
                        withAnimation {
                            self.showCard = true
                        }
                    } label : {
                        HStack {
                            Spacer()
                            Text("Delete")
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .frame(height: 50, alignment: .center)
                }  .background(Color.red)
                        .buttonStyle(BorderlessButtonStyle())
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
            }
            else {
                VStack {
                    Button {
                        if productName.count >= 2 {
                            addProduct()
                            alertTitle = "Product Saved!"
                            alertImage = "checkmark.seal.fill"
                            color = .green
                            withAnimation {
                                self.showCard = true
                            }
                        }
                        else {
                            alertTitle =  "Something went wrong!"
                        alertMessage = "Please enter the product name with atleast 2 characters length. Make sure to set its type and expiry date too!"
                            showAlert = true
                        }
                    } label : {
                        HStack {
                            Spacer()
                            Text("Save")
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .frame(height: 50, alignment: .center)
                                                            
                    }
                    .background(Color.gray)
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(10)
                    .padding(.bottom, 10)
                  
                        Button {
                            if productName.count >= 2 {
                                addProduct()
                                alertTitle = "Product Saved \n&\n All Done!"
                                alertImage = "checkmark.seal.fill"
                                color = .green
                                withAnimation {
                                    self.showCard = true
                                }
                            }
                            else {
                                alertTitle =  "Something went wrong!"
                            alertMessage = "Please enter the product name with atleast 2 characters length. Make sure to set its type and expiry date too!"
                                showAlert = true
                            }
                        } label : {
                            HStack {
                                Spacer()
                                Text("Save & Done")
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .frame(height: 50, alignment: .center)
                                                                
                        }
                        .background(Color.blue)
                        .buttonStyle(BorderlessButtonStyle())
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                               
                    Button {
                        resetForm()
                        alertTitle = "Product Discarded!"
                        alertImage = "xmark.seal.fill"
                        color = .red
                        withAnimation {
                            self.showCard = true
                        }
                    } label : {
                        HStack {
                            Spacer()
                            Text("Discard")
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .frame(height: 50, alignment: .center)
                                                            
                    }
                    .background(Color.red)
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(10)
                    .padding(.bottom, 0)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
        }
    }
    func resetForm() {
        DispatchQueue.main.async {
            productName = ""
            productType = "Grocery"
            expiryDate = Date().dayAfter
        }
    }
    func addProduct() {
        let product = Product(context: viewContext)
        product.productID = UUID()
        product.name = productName
        product.type = productType
        product.expiryDate = modifyDate(date: expiryDate)
        product.dateStamp = Date()
        product.deleteAfter = Int16( UserDefaults.standard.integer(forKey: "numberOfDays") == 0 ? 1 : UserDefaults.standard.integer(forKey: "numberOfDays"))
        
        notification.saveContext(viewContext: viewContext)
       
        notification.sendTimeNotification(product: product)
        resetForm()
        
    }
    func modifyDate(date: Date) -> Date {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let dateStr = formatter.string(from: date)
        let modifiedDateStr = "\(dateStr), 8:30 AM"
        formatter.timeStyle = .short
        let modifiedDate = formatter.date(from: modifiedDateStr)
        //print("modified date:\(String(describing: modifiedDate))")
        return modifiedDate ?? date
    }
    
    func saveChanges() {
        if let prod = products.first(where: {$0.DateStamp == product.DateStamp})  {
            print("------------Saving changes for \(prod.getName)------------")
            
            notification.removeNotification(product: product)
            
            prod.name = productName
            prod.type = productType
            prod.expiryDate = expiryDate
            prod.dateStamp = Date()
            
            notification.saveContext(viewContext: viewContext)
            notification.sendTimeNotification(product: product)
            
            // dismiss the view.
        
        }
    }
    
    func deleteProduct() {
        notification.removeNotification(product: product)
        
        viewContext.delete(product)
        notification.saveContext(viewContext: viewContext)
        
        DispatchQueue.main.async {
            resetFormInputs()
        }
       
    }
    
    func resetFormInputs() {
        productName = ""
        productType = "Grocery"
        expiryDate = Date().dayAfter
    }
}

struct ProductForm_Previews: PreviewProvider {
    static var previews: some View {
        ProductForm(product: Product(),productName: .constant(""), productType: .constant(""), expiryDate: .constant(Date().dayAfter), showProductScanningView: .constant(false), showDateScanningView: .constant(false), alertTitle: .constant(""), alertImage: .constant(""), alertMessage: .constant(""), color: .constant(.green), showCard: .constant(false), showAlert: .constant(false), viewTag: .constant(0))
    }
}




