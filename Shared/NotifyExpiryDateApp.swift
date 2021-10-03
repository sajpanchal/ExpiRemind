//
//  NotifyExpiryDateApp.swift
//  Shared
//
//  Created by saj panchal on 2021-09-19.
//

import SwiftUI
import os
@main
struct NotifyExpiryDateApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

