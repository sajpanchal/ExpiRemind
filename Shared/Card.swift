//
//  Card.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-10-17.
//

import SwiftUI

struct Card: View {
    //card text
    @State var title: String
    //card image name.
    @State var image: String
    //card bg color
    @State var color: Color
    //showing icon
    @State var showIcon = false
    
    var body: some View {
        ZStack {
            // set color view as a rectangle view to the bottom of the 3D stack
            color
                .frame(width: 250, height: 180, alignment: .center)
                .cornerRadius(10)
                .shadow(radius: 5.0)
            // put the card view at the top of it.
            VStack {
                Spacer()
                //if icon is visible (which will as soon as this view is going to appear)
                    if showIcon {
                        // show the icon view
                        ZStack {
                            // set circle as a bottom view
                            Circle()
                                .frame(width: 50, height: 50, alignment: .center)
                            
                            //above circle display image with a given string
                            Image(systemName: image)
                                .font(.title)
                                .foregroundColor(color)
                        }
                        .frame(width: 50, height: 50, alignment: .leading)
                        //transition of scale of this view with animation
                        .transition(.scale)
                    }
                
                //set the text of the card.
                Text(title)
                    .font(.body)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(width: 250, height: 250, alignment: .center)
            .foregroundColor(.white)
        }
        //show icon with animation
        .onAppear( perform: {
            withAnimation {
                showIcon = true
            }
        })
        //hide icon with animation
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
