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

    case surviveFatalDamage(remainingHealth: Int)
    case ignoreAllAbilities
    case negateFirstAttack
    case bonusDamagePerMerge(amount: Int)
    case healFirstTimeBelowHalf(percent: Double)
    case splashDamage(amount: Int)
}

struct Ability: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let effect: AbilityEffect
    let isOneTime: Bool
}
