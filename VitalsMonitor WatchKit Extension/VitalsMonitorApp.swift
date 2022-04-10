//
//  VitalsMonitorApp.swift
//  VitalsMonitor WatchKit Extension
//
//  Created by James Foley on 4/9/22.
//

import SwiftUI

@main
struct VitalsMonitorApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
