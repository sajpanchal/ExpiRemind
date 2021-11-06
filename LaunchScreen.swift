//
//  LaunchScreen.swift
//  NotifyExpiryDate (iOS)
//
//  Created by saj panchal on 2021-10-26.
//

import SwiftUI
import AuthenticationServices

struct LaunchScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var isSignedIn: Bool
    var body: some View {
        VStack {
            Spacer()
            Image("appstore")
                .resizable()
                .frame(width: 250, height: 250, alignment: .center)
                .cornerRadius(10.0)
            Text("ExpiRemind")
                .font(.title)
                .fontWeight(.black)
                .foregroundColor(Color(red: 0.832, green: 0.316, blue: 0.16, opacity: 1))
            Spacer()
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
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            
        }
        .onAppear(perform: {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            print("Reminder Time:",UserDefaults.standard.object(forKey: "reminderTime")as? Date ?? "found nil")
            if UserDefaults.standard.object(forKey: "reminderTime") as? Date == nil {
                UserDefaults.standard.set(dateFormatter.date(from: "12:00 AM"), forKey: "reminderTime")
                print("reminder time is set.")
            }
        })
       
    }
    func showAppleLoginView() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.performRequests()
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen(isSignedIn: .constant(false))
    }
}
