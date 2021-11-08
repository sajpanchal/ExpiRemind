//
//  LaunchScreen.swift
//  NotifyExpiryDate (iOS)
//
//  Created by saj panchal on 2021-10-26.
//

import SwiftUI
import AuthenticationServices

struct LaunchScreen: View {
    // env var to get phone color scheme (dark/light)
    @Environment(\.colorScheme) private var colorScheme
    
    // to check whether user is signed in or not
    @Binding var isSignedIn: Bool
    
    var body: some View {
        VStack {
            
            // occupy remaining space
            Spacer()
            
            //App logo
            Image("appstore")
                .resizable()
                .frame(width: 150, height: 150, alignment: .center)
                .cornerRadius(10.0)
            
            //App Display name
            Text("ExpiRemind")
                .font(.title)
                .fontWeight(.black)
                .foregroundColor(Color(red: 0.832, green: 0.316, blue: 0.16, opacity: 1))
            
            Spacer()
            
            //a view that is part of the AuthenticationServices with request and onCompetion closures.
            //request is the closure that will request the user credentials on button tap.
            //onCOmpletion is a closure that will validates and authenticates the user login and if successful, this entire view will disappear.
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success:
                    isSignedIn = true
                case .failure(let error):
                    isSignedIn = false
                    print(error.localizedDescription)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
            .padding()
            // set the button style based on phone color scheme.
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            
        }
        //on view appear, set the default reminder time for notification triggers.
        .onAppear(perform: setDefaultReminderTime)
    }
        
    func setDefaultReminderTime() {
        // set the date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        print("Reminder Time:",UserDefaults.standard.object(forKey: "reminderTime")as? Date ?? "found nil")
        
        // if the object with key is not set
        if UserDefaults.standard.object(forKey: "reminderTime") as? Date == nil {
            // set the reminder time to 12:00 PM by default.
            UserDefaults.standard.set(dateFormatter.date(from: "12:00 PM"), forKey: "reminderTime")
            print("reminder time is set.")
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen(isSignedIn: .constant(false))
    }
}
