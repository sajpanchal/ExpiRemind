//
//  ProductForm.swift
//  NotifyExpiryDate (iOS)
//
//  Created by saj panchal on 2021-10-26.
//

import SwiftUI

struct ProductForm: View {
    //managed object context variable of cloudkit.
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.colorScheme) private var colorScheme
    //fetched records from cloudkit Product entity.
    @FetchRequest(entity: Product.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Product.expiryDate, ascending: true)]) var products: FetchedResults<Product>
    // product variable that is passed from content view is having a property wrapper ObservedObject. i.e. this object is going to be changed if the original object is changed. also, it will re-render this view if it's values are in use.
    @ObservedObject var product: Product
    //same as above to share and sync notification object throughout the app
    @EnvironmentObject var notification: CustomNotification
    
    // variables to be used in product form ui. they have a binding prop wrapper. i.e. if they change in this view they are also going to change in a view from which they are passed.
    let productTypes = ["Document","Electronics","Grocery","Subscription", "Other"]
    @Binding var productName: String
    @Binding var productType: String
    @Binding var expiryDate: Date
    
    // variables passed from content view to manipulate camera view.
    @Binding var showProductScanningView: Bool
    @Binding var showDateScanningView: Bool
    
    //variables passed from content view to manipulare alert or card.
    @Binding var alertTitle: String
    @Binding var alertImage: String
    @Binding var alertMessage: String
    @Binding var color: Color
    @Binding var showCard: Bool
    @Binding var showAlert: Bool
    
    //variable passed from content view to manipulate this product form as add product or edit product form.
    @Binding var viewTag: Int

    var body: some View {
        Form {
            
            // text input for product name
            Section(header: Text("Enter/Scan Product Name:")) {
                HStack {
                    TextField("Product name", text:$productName)
                    
                    Spacer()
                    
                    // tappable image to scan the product with camera view visionkit capabilities.
                    Image(systemName: "camera.viewfinder")
                        .onTapGesture {
                            // show the product scanning camera view.
                            showProductScanningView = true
                        }
                }
            }
            
            //picker input for product type
            Section(header: Text("Select Product Category:")) {
                
                //picker with text and selection (array element that has been selected and will assign that to this binding variable)
                Picker("Product category is", selection: $productType) {
                    // content of the picker that will iterate through the product type array.
                    ForEach(productTypes, id: \.self) {
                        // show individual types in text format in a list.
                        Text($0)
                    }
                }
            }
            
            //date picker input to set product expiry date.
            Section(header: Text("Enter/Scan Product Expiry:")) {
                HStack {
                    //date picker view with selection (stores selected date to binding variable), date range (from tomorrow to any future date), displayComponent (date or time or both).
                    DatePicker(selection: $expiryDate, in: Date().dayAfter..., displayedComponents: .date) {
                        Text("Expiry date is")
                    }
                    .datePickerStyle(.compact)
                    .accentColor(.secondary)
                    
                    Spacer()
                    
                    //tappable image to scan the date instead.
                    Image(systemName: "camera.viewfinder")
                        .onTapGesture {
                            // show the date scanning camera view.
                            showDateScanningView = true
                        }
                }
            }
            
            //show the edit product form
            if viewTag == 1 {
                VStack {
                    // save the existing product in cloudkit after editing.
                    Button {
                        //manipulate card text and bgcolor.
                        alertTitle = "Saved Changes!"
                        alertImage = "checkmark.seal.fill"
                        color = .green
                        
                        //handle product, notification and clodkit context.
                        saveChanges()
                        
                        //show card with animation
                        withAnimation {
                            showCard = true
                        }
                    }
                    // button appearance
                    label : {
                        HStack {
                            Spacer()
                            
                            Text("Save Product")
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                            
                            Spacer()
                        }
                        .frame(height: 40, alignment: .center)
                    }
                    .background(Color.gray)
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(100)
                    .padding(.bottom, 10)
                    
                    //discard this product from cloudkit.
                    Button {
                        // manipulate the card text and bgcolor.
                        alertTitle = "Product Discarded!"
                        alertImage = "xmark.seal.fill"
                        color = .red
                        
                       
                        
                        //show card with animation
                        withAnimation {
                            self.showCard = true
                          
                        }
                        let _ = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { (timer) in
                            
                        deleteProduct()
                        }
                        //delete the product from cloudkit
                        if self.showCard == false {
                       
                        }
                    }
                    // button appearance
                    label : {
                        HStack {
                            Spacer()
                            
                            Text("Delete Product")
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                            Spacer()
                        }
                        .frame(height: 40, alignment: .center)
                }
                .background(Color.red)
                .buttonStyle(BorderlessButtonStyle())
                .cornerRadius(100)
                .padding(.bottom, 10)
                
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
            }
            // show product form to add a new product.
            else {
                VStack {
                    Button {
                        // if product name is valid.
                        if productName.count >= 2 {
                            
                            //add a new product in a cloudkit
                            addProduct()
                            
                            // manipulate the card text and bgcolor.
                            alertTitle = "Product Saved!"
                            alertImage = "checkmark.seal.fill"
                            color = .green
                            
                            //show card with animation
                            withAnimation {
                                self.showCard = true
                            }
                        }
                        
                        //if product name is invalid.
                        else {
                            alertTitle =  "Invalid Input!"
                            alertMessage = "Please enter the product name with atleast 2 characters length. Make sure to set its type and expiry date too!"
                            showAlert = true
                        }
                    }
                    // button appearance.
                    label : {
                        HStack {
                            Spacer()
                            
                            Text("Save Product")
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                            
                            Spacer()
                        }
                        .frame(height: 40, alignment: .center)
                                                            
                    }
                    .background(Color.gray)
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(100)
                    .padding(.bottom, 10)
                    
                    //save & done button
                    Button {
                        // if product name is valid.
                        if productName.count >= 2 {
                            //add a new product in a cloudkit
                            addProduct()
                            
                            // manipulate the card text and bgcolor.
                            alertTitle = "Product Saved \n&\n All Done!"
                            alertImage = "checkmark.seal.fill"
                            color = .green
                            
                            //show card with animation
                            withAnimation {
                                self.showCard = true
                            }
                        }
                        else {
                            //if product name is invalid.
                            alertTitle =  "Something went wrong!"
                            alertMessage = "Please enter the product name with atleast 2 characters length. Make sure to set its type and expiry date too!"
                            
                            //show the alert.
                            showAlert = true
                        }
                    }
                    // button appearance.
                    label : {
                        HStack {
                            Spacer()
                            Text("Save Product & Done")
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                            Spacer()
                        }
                        .frame(height: 40, alignment: .center)
                    }
                    .background(Color.blue)
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(100)
                    .padding(.bottom, 10)
                        
                    //discard button
                    Button {
                        //reset form with default values.
                        resetForm()
                        
                        // manipulate the card text and bgcolor.
                        alertTitle = "Form Cleared!"
                        alertImage = "xmark.seal.fill"
                        color = .red
                        
                        //show card with animation
                        withAnimation {
                            self.showCard = true
                        }
                    }
                    // button appearance.
                    label : {
                        HStack {
                            Spacer()
                            
                            Text("Clear Form")
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                            
                            Spacer()
                        }
                        .frame(height: 40, alignment: .center)
                                                            
                    }
                    .background(Color.red)
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(100)
                    .padding(.bottom, 0)
                  
               
                }
                // modifiers to button stack
                .listRowBackground(Color.clear) // clear the stack bg color.
                .listRowInsets(EdgeInsets()) //set the row width to the edge of the form.
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
    
    //add a new product and save it.
    func addProduct() {
        // create a new product record.
        let product = Product(context: viewContext)
        
        //assign property values.
        product.productID = UUID()
        product.name = productName
        product.type = productType
        product.expiryDate = Product.modifyDate(date: expiryDate)
        product.dateStamp = Date()
        product.deleteAfter = Int16( UserDefaults.standard.integer(forKey: "numberOfDays") == 0 ? 1 : UserDefaults.standard.integer(forKey: "numberOfDays"))
        product.isNotificationSet = Product.checkNumberOfReminders(products: products) < 20 ? true: false
        //save the managed object context with a new record added.
        Product.saveContext(viewContext: viewContext)
       
        //create a notification trigger request for new product.
        notification.sendTimeNotification(product: product)
        
        //reset the product form.
        resetForm()
    }

    func saveChanges() {
        // find the product from the fetched cloudkit entity with date stamp of currently edited product.
        if let prod = products.first(where: {$0.DateStamp == product.DateStamp})  {
            print("------------Saving changes for \(prod.getName)------------")
            // remove the old notification trigger request. first.
            notification.removeNotification(product: product)
            
            //replace the product properties with new changes.
            prod.name = productName
            prod.type = productType
            prod.expiryDate = Product.modifyDate(date: expiryDate)
            prod.dateStamp = Date()
            
            //save the changes made in managedObjectContext
            Product.saveContext(viewContext: viewContext)
            
            //create a new notification trigger request.
            notification.sendTimeNotification(product: product)
        }
    }
    
    func deleteProduct() {
        
        //remove the product notification trigger request.
        notification.removeNotification(product: product)
        
        //delete the product from managed object context.
        viewContext.delete(product)
        
        //save the updated managed object context in cloudkit.
        Product.saveContext(viewContext: viewContext)
        
        //reset the product form with default values.
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




