//
//  HealthManager.swift
//  Fitagochi sync
//
//  Created by Raheem Crayton on 4/24/25.
//

import Foundation
import HealthKit

class HealthManager {
    let healthStore = HKHealthStore()

    func requestHealthKitAccess() {
        let workoutType = HKObjectType.workoutType()
        let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount)!

        let readTypes: Set = [workoutType, stepCount]

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            if success {
                print("✅ HealthKit authorization granted.")
            } else {
                print("❌ HealthKit authorization failed:", error ?? "")
            }
        }
    }

    func fetchTodayWorkoutData(completion: @escaping (Bool) -> Void) {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())

        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: 0, sortDescriptors: nil) { _, results, error in
            if let workouts = results as? [HKWorkout], !workouts.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }

        healthStore.execute(query)
    }

    func sendWorkoutStatusToFlask(workedOut: Bool) {
        guard let url = URL(string: "http://192.168.217.164:5050/pet/update") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "user_id": "raheem",
            "worked_out_today": workedOut
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("❌ Error sending data:", error)
            } else {
                print("✅ Synced with Flask!")
            }
        }.resume()
    }
    
    func fetchPetStatusFromFlask(userID:String, completion: @escaping (PetStatus?) -> Void) {
        guard let url = URL(string: "http://192.168.217.164:5050/pet?user_id=\(userID)") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                       print("📥 Response status code: \(httpResponse.statusCode)")
                   }
            if let data = data {
                let body = String(data: data, encoding: .utf8) ?? "no response"
                print("📦 Response body: \(body)")
                do{
                    let petsStatus = try JSONDecoder().decode(PetStatus.self, from: data)
                    completion(petsStatus)
                    
                }catch {
                    print("❌ Failed to decode pet status")
                    completion(nil)
                }
            }else{
                    print("❌ Error fetching data:", error ?? "No error")
                    completion(nil)
                }
        }.resume()
    }
        
}

