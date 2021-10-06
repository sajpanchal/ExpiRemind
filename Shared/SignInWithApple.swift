//
//  SignInWithApple.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-10-06.
//

import SwiftUI
import AuthenticationServices
struct SignInWithApple: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIViewType {
        return ASAuthorizationAppleIDButton()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    typealias UIViewType = ASAuthorizationAppleIDButton
    
    
   
}


