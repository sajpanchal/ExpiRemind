//
//  PreferancesView.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-10-04.
//

import SwiftUI

struct PreferencesView: View {
    @State var isNotificationEnabled: Bool = false
    let daysCollection = [1, 3, 7, 30]
    @State var numberOfDays = 30
    @ObservedObject var notifications = CustomNotification()
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Reminders")) {
                        Toggle("Remind before product(s) Expire:", isOn: $isNotificationEnabled)
                    }
                    Section(header: Text("Delete product after 'x' days of expiry")) {
                        Picker("Select the number of days", selection: $numberOfDays) {
                            ForEach(daysCollection, id: \.self) {
                                Text("\($0) Days")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Preferences")
            .navigationBarItems( trailing: Button("Save") {
                if isNotificationEnabled {
                    notifications.isNotificationEnabled = false
                    notifications.removeAllNotifications()
                }
            })
        }       
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
