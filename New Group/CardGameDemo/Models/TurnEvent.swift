//
//  TurnEvent.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/29/26.
//


import Foundation

enum TurnEventType {
    case cardPlayed
    case attack
    case ability
    case merge
    case cardDefeated
    case healing
}

struct TurnEvent: Identifiable {
    let id = UUID()
    let type: TurnEventType
    let message: String
}
