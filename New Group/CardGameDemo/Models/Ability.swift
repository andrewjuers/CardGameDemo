//
//  Ability.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/26/26.
//


import Foundation

enum AbilityEffect {
    case reduceIncomingDamage(amount: Int)
    case healAtTurnEnd(amount: Int)
    case retaliate(amount: Int)
    case damageOnDefeat(amount: Int)

    // Future one-time abilities
    case surviveFatalDamage(remainingHealth: Int)
    case healBelowHalf(amount: Int)
}

struct Ability: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let effect: AbilityEffect
    let isOneTime: Bool
}
