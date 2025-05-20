//
//  Fitagochi_syncApp.swift
//  Fitagochi sync
//
//  Created by Raheem Crayton on 4/24/25.
//

import SwiftUI

@main
struct FitagotchiSyncApp: App {
    let healthManager = HealthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    healthManager.requestHealthKitAccess()
                    healthManager.fetchTodayWorkoutData { workedOutToday in
                        healthManager.sendWorkoutStatusToFlask(workedOut: workedOutToday)
                    }
                }
        }
    }
}
