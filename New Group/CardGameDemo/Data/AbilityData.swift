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
    
    static var lastStand: Ability {
        Ability(
            name: "Last Stand",
            description: "The first time this card would be defeated, it survives with 1 health.",
            effect: .surviveFatalDamage(
                remainingHealth: 1
            ),
            isOneTime: true
        )
    }

    static var immune: Ability {
        Ability(
            name: "Immune",
            description: "This card ignores all ability effects, including friendly abilities.",
            effect: .ignoreAllAbilities,
            isOneTime: false
        )
    }

    static var shield: Ability {
        Ability(
            name: "Shield",
            description: "Negate all damage from the first attack that hits this card.",
            effect: .negateFirstAttack,
            isOneTime: true
        )
    }

    static var hunter: Ability {
        Ability(
            name: "Hunter",
            description: "Attacks deal 2 additional damage for each card merged into the opposing card.",
            effect: .bonusDamagePerMerge(
                amount: 2
            ),
            isOneTime: false
        )
    }

    static var secondWind: Ability {
        Ability(
            name: "Second Wind",
            description: "The first time this card falls below half health, heal 50% of its maximum health.",
            effect: .healFirstTimeBelowHalf(
                percent: 0.5
            ),
            isOneTime: true
        )
    }

    static var splash: Ability {
        Ability(
            name: "Splash",
            description: "Whenever this card attacks, deal 1 damage to enemy cards adjacent to the target.",
            effect: .splashDamage(
                amount: 1
            ),
            isOneTime: false
        )
    }
}
