//
//  Card.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-10-17.
//

import SwiftUI

struct Card: View {
    @State var title: String
    @State var image: String
    @State var color: Color
    var body: some View {
        ZStack {
            Color(red: 0.917, green: 0.917, blue: 0.917, opacity: 1)
                .frame(width: 250, height: 180, alignment: .center)
                .cornerRadius(10)
                .shadow(radius: 5.0)
            VStack {
                Spacer()
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(color)
                ZStack {
                    Circle()
                        .frame(width: 50, height: 50, alignment: .center)
                        .foregroundColor(color)
                    Image(systemName: image)
                        .font(.title)
                        .foregroundColor(Color(red: 0.917, green: 0.917, blue: 0.917, opacity: 1))
                }
                
                Spacer()
            }
            .frame(width: 250, height: 250, alignment: .center)
            .foregroundColor(.white)
           
        }
        
        
        
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        Card(title: "Product Saved!", image: "checkmark.seal.fill", color: .green)
    }
}
