//
//  Fitagochi_syncApp.swift
//  Fitagochi sync
//
//  Created by Raheem Crayton on 4/24/25.
//

import SwiftUI

@main
struct FitagotchiSyncApp: App {
    @StateObject var session = UserSession()
    let healthManager = HealthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
                .onAppear {
                    healthManager.requestHealthKitAccess()
                    healthManager.fetchTodayWorkoutData { workedOutToday in
                        if !session.userID.isEmpty {
                            healthManager.sendWorkoutStatusToFlask(userID: session.userID,workedOut: workedOutToday)
                        }
                    }
                }
        }
    }
}
