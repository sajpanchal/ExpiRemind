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
    @State var showIcon = false
    
    var body: some View {
        ZStack {
            color
                .frame(width: 250, height: 180, alignment: .center)
                .cornerRadius(10)
                .shadow(radius: 5.0)
            VStack {
                Spacer()
                    if showIcon {
                        ZStack {
                            Circle()
                                .frame(width: 50, height: 50, alignment: .center)
                            Image(systemName: image)
                                .font(.title)
                                .foregroundColor(color)
                        }
                        .frame(width: 50, height: 50, alignment: .leading)
                        .transition(.scale)
                    }
                Text(title)
                    .font(.body)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(width: 250, height: 250, alignment: .center)
            .foregroundColor(.white)
        }
        .onAppear( perform: {
            withAnimation {
                showIcon = true
            }
        })
        .onDisappear(perform: {
            showIcon = false
        })
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        Card(title: "Product Saved!", image: "checkmark.seal.fill", color: .green)
    }
}
