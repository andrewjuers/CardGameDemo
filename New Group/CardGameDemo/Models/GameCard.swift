//
//  GameCard.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/17/26.
//

import Foundation

struct Move: Identifiable {
    let id = UUID()
    let name: String
    let damage: Int
    let cost: Int
}

struct GameCard: Identifiable {
    let id = UUID()

    let name: String
    var health: Int
    let maxHealth: Int
    let moves: [Move]
    let abilities: [Ability]

    let componentCount: Int
    var playedTurn: Int?

    var usedAbilityIDs: Set<UUID>

    init(
        name: String,
        health: Int,
        maxHealth: Int? = nil,
        moves: [Move],
        abilities: [Ability] = [],
        componentCount: Int = 1,
        playedTurn: Int? = nil,
        usedAbilityIDs: Set<UUID> = []
    ) {
        self.name = name
        self.health = health
        self.maxHealth = maxHealth ?? health
        self.moves = moves
        self.abilities = abilities
        self.componentCount = componentCount
        self.playedTurn = playedTurn
        self.usedAbilityIDs = usedAbilityIDs
    }
}
