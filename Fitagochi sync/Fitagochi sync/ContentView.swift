//
//  ContentView.swift
//  Fitagochi sync
//
//  Created by Raheem Crayton on 4/24/25.
//

import SwiftUI

struct ContentView: View {
    @State private var petstatus: PetStatus?
    @State private var isLoading = false
    @State private var userIDInput: String = ""
    @State private var userID: String = ""
    let healthmanager = HealthManager()
    
    var body: some View {
        
        if userID.isEmpty {
            VStack {
                    Text("🐾 Welcome to Fitagotchi")
                        .font(.title)
                        .padding(.bottom)

                    TextField("Enter your username", text: $userIDInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button("Continue") {
                        userID = userIDInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .padding()
        }else{
            VStack (spacing:20){
                Text("🐾 Fitagochi sync")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                if let pet = petstatus {
                    Text("🐶 \(pet.name)")
                        .font(.title)
                    Text("❤️ Health: \(pet.health)")
                    Text("😊 Happiness: \(pet.happiness)")
                    Text("🗓️ Last Workout: \(pet.last_workout_date ?? "Never")")
                }else{
                    Text("No pet data yet...")
                        .foregroundColor(.gray)
                }
                if isLoading {
                    ProgressView()
                }
                
                Button(action:syncPetStatus){
                    Text("Sync \(Image(systemName:"arrow.trianglehead.2.clockwise.rotate.90"))")
                        .foregroundColor(.blue)
                        .padding()
                        .cornerRadius(10)
                }
                Text("Your pet thanks you!")
            }
        }
    }
    func syncPetStatus() {
        isLoading = true
        healthmanager.fetchPetStatusFromFlask(userID: userID) { pet in
            DispatchQueue.main.async {
                self.petstatus = pet
                self.isLoading = false
            }
        }
    }
}

#Preview {
    ContentView()
}
