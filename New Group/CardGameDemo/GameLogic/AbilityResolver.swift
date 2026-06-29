//
//  AbilityResolver.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/26/26.
//


import Foundation

struct AbilityResolver {

    static func adjustedAttackDamage(
        _ damage: Int,
        against card: GameCard
    ) -> Int {
        var finalDamage = damage

        for ability in card.abilities {
            switch ability.effect {
            case .reduceIncomingDamage(let amount):
                finalDamage -= amount

            default:
                break
            }
        }

        return max(0, finalDamage)
    }

    static func retaliationDamage(
        from card: GameCard
    ) -> Int {
        var totalDamage = 0

        for ability in card.abilities {
            switch ability.effect {
            case .retaliate(let amount):
                totalDamage += amount

            default:
                break
            }
        }

        return totalDamage
    }

    static func defeatDamage(
        from card: GameCard
    ) -> Int {
        var totalDamage = 0

        for ability in card.abilities {
            switch ability.effect {
            case .damageOnDefeat(let amount):
                totalDamage += amount

            default:
                break
            }
        }

        return totalDamage
    }

    static func endTurnHealing(
        for card: GameCard
    ) -> Int {
        var totalHealing = 0

        for ability in card.abilities {
            switch ability.effect {
            case .healAtTurnEnd(let amount):
                totalHealing += amount

            default:
                break
            }
        }

        return totalHealing
    }
}
