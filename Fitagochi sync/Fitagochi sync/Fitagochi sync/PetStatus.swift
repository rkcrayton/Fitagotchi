//
//  PetStatus.swift
//  Fitagochi sync
//
//  Created by Raheem Crayton on 5/20/25.
//


struct PetStatus: Codable {
    let name: String
    let health: Int
    let happiness: Int
    let last_workout_date: String?
}
