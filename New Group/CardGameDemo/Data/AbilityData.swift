//
//  AbilityData.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/26/26.
//


import Foundation

struct AbilityData {

    static let hardShell = Ability(
        name: "Hard Shell",
        description: "Reduce damage from each incoming attack by 1.",
        effect: .reduceIncomingDamage(amount: 1),
        isOneTime: false
    )

    static let regenerate = Ability(
        name: "Regenerate",
        description: "Heal 1 health at the end of each turn.",
        effect: .healAtTurnEnd(amount: 1),
        isOneTime: false
    )

    static let spikes = Ability(
        name: "Spikes",
        description: "When hit by an attack, deal 1 damage back to the attacker.",
        effect: .retaliate(amount: 1),
        isOneTime: false
    )

    static let deathBurst = Ability(
        name: "Death Burst",
        description: "When defeated, deal 2 damage to the opposing card.",
        effect: .damageOnDefeat(amount: 2),
        isOneTime: true
    )
}
