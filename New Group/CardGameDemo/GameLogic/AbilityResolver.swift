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
        if isImmune(card) {
            return damage
        }

        var adjustedDamage = damage

        for ability in card.abilities {
            switch ability.effect {
            case .reduceIncomingDamage(let amount):
                adjustedDamage -= amount

            default:
                break
            }
        }

        return max(adjustedDamage, 0)
    }

    static func retaliationDamage(
        from card: GameCard
    ) -> Int {
        if isImmune(card) {
            return 0
        }

        var total = 0

        for ability in card.abilities {
            switch ability.effect {
            case .retaliate(let amount):
                total += amount

            default:
                break
            }
        }

        return total
    }

    static func defeatDamage(
        from card: GameCard
    ) -> Int {
        if isImmune(card) {
            return 0
        }

        var total = 0

        for ability in card.abilities {
            switch ability.effect {
            case .damageOnDefeat(let amount):
                total += amount

            default:
                break
            }
        }

        return total
    }

    static func endTurnHealing(
        for card: GameCard
    ) -> Int {
        if isImmune(card) {
            return 0
        }

        var total = 0

        for ability in card.abilities {
            switch ability.effect {
            case .healAtTurnEnd(let amount):
                total += amount

            default:
                break
            }
        }

        return total
    }
    
    static func isImmune(
        _ card: GameCard
    ) -> Bool {
        card.abilities.contains { ability in
            if case .ignoreAllAbilities = ability.effect {
                return true
            }

            return false
        }
    }
    
    static func unusedLastStandAbility(
        for card: GameCard
    ) -> Ability? {
        guard !isImmune(card) else {
            return nil
        }

        return card.abilities.first { ability in
            guard !card.usedAbilityIDs.contains(ability.id) else {
                return false
            }

            if case .surviveFatalDamage = ability.effect {
                return true
            }

            return false
        }
    }
    
    static func unusedShieldAbility(
        for card: GameCard
    ) -> Ability? {
        guard !isImmune(card) else {
            return nil
        }

        return card.abilities.first { ability in
            guard !card.usedAbilityIDs.contains(ability.id) else {
                return false
            }

            if case .negateFirstAttack = ability.effect {
                return true
            }

            return false
        }
    }
    
    static func hunterBonusDamage(
        from attacker: GameCard,
        against target: GameCard
    ) -> Int {
        guard !isImmune(attacker),
              !isImmune(target) else {
            return 0
        }

        let additionalComponents = max(
            target.componentCount - 1,
            0
        )

        var totalBonus = 0

        for ability in attacker.abilities {
            switch ability.effect {
            case .bonusDamagePerMerge(let amount):
                totalBonus +=
                    amount * additionalComponents

            default:
                break
            }
        }

        return totalBonus
    }
    
    static func unusedSecondWindAbility(
        for card: GameCard
    ) -> Ability? {
        guard !isImmune(card) else {
            return nil
        }

        return card.abilities.first { ability in
            guard !card.usedAbilityIDs.contains(ability.id) else {
                return false
            }

            if case .healFirstTimeBelowHalf = ability.effect {
                return true
            }

            return false
        }
    }
    
    static func splashDamage(
        from card: GameCard
    ) -> Int {
        guard !isImmune(card) else {
            return 0
        }

        var totalDamage = 0

        for ability in card.abilities {
            switch ability.effect {
            case .splashDamage(let amount):
                totalDamage += amount

            default:
                break
            }
        }

        return totalDamage
    }
}
