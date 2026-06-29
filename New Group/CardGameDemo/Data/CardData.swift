//
//  CardData.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/22/26.
//

import Foundation

struct CardData {

    static let allCards: [GameCard] = [

        // MARK: - 1 Cost Cards

        GameCard(
            cardID: .dog,
            name: "Dog",
            health: 7,
            moves: [
                Move(
                    name: "Bite",
                    damage: 2,
                    cost: 1
                )
            ]
        ),

        GameCard(
            cardID: .duck,
            name: "Duck",
            health: 6,
            moves: [
                Move(
                    name: "Peck",
                    damage: 3,
                    cost: 1
                )
            ]
        ),

        GameCard(
            cardID: .deer,
            name: "Deer",
            health: 9,
            moves: [
                Move(
                    name: "Strike",
                    damage: 1,
                    cost: 1
                )
            ]
        ),

        // MARK: - 2 Cost Cards

        GameCard(
            cardID: .flamingo,
            name: "Flamingo",
            health: 8,
            moves: [
                Move(
                    name: "Sling",
                    damage: 5,
                    cost: 2
                )
            ]
        ),

        GameCard(
            cardID: .hippo,
            name: "Hippo",
            health: 9,
            moves: [
                Move(
                    name: "Chomp",
                    damage: 4,
                    cost: 2
                )
            ]
        ),

        GameCard(
            cardID: .beetle,
            name: "Beetle",
            health: 6,
            moves: [
                Move(
                    name: "Charge",
                    damage: 6,
                    cost: 2
                )
            ]
        ),

        GameCard(
            cardID: .wolf,
            name: "Wolf",
            health: 7,
            moves: [
                Move(
                    name: "Lunge",
                    damage: 5,
                    cost: 2
                )
            ]
        ),

        GameCard(
            cardID: .turtle,
            name: "Turtle",
            health: 11,
            moves: [
                Move(
                    name: "Bash",
                    damage: 3,
                    cost: 2
                )
            ]
        ),

        // MARK: - 3 Cost Cards

        GameCard(
            cardID: .lion,
            name: "Lion",
            health: 9,
            moves: [
                Move(
                    name: "Maul",
                    damage: 7,
                    cost: 3
                )
            ]
        ),

        GameCard(
            cardID: .rhino,
            name: "Rhino",
            health: 12,
            moves: [
                Move(
                    name: "Stampede",
                    damage: 6,
                    cost: 3
                )
            ]
        ),

        // MARK: - Multiple Move Cards

        GameCard(
            cardID: .snake,
            name: "Snake",
            health: 7,
            moves: [
                Move(
                    name: "Bite",
                    damage: 3,
                    cost: 1
                ),
                Move(
                    name: "Venom Strike",
                    damage: 6,
                    cost: 3
                )
            ]
        ),

        GameCard(
            cardID: .eagle,
            name: "Eagle",
            health: 8,
            moves: [
                Move(
                    name: "Claw",
                    damage: 3,
                    cost: 1
                ),
                Move(
                    name: "Dive Bomb",
                    damage: 5,
                    cost: 3
                )
            ]
        ),
        
        // MARK: - 1 Cost Ability Cards

        GameCard(
            cardID: .armadillo,
            name: "Armadillo",
            health: 7,
            moves: [
                Move(
                    name: "Slash",
                    damage: 1,
                    cost: 1
                )
            ],
            abilities: [
                AbilityData.hardShell
            ]
        ),

        GameCard(
            cardID: .salamander,
            name: "Salamander",
            health: 5,
            moves: [
                Move(
                    name: "Whip",
                    damage: 2,
                    cost: 1
                )
            ],
            abilities: [
                AbilityData.regenerate
            ]
        ),

        GameCard(
            cardID: .hedgehog,
            name: "Hedgehog",
            health: 5,
            moves: [
                Move(
                    name: "Tackle",
                    damage: 2,
                    cost: 1
                )
            ],
            abilities: [
                AbilityData.spikes
            ]
        ),

        GameCard(
            cardID: .firefly,
            name: "Firefly",
            health: 4,
            moves: [
                Move(
                    name: "Flash",
                    damage: 2,
                    cost: 1
                )
            ],
            abilities: [
                AbilityData.deathBurst
            ]
        ),

        // MARK: - 2 Cost Ability Cards

        GameCard(
            cardID: .mole,
            name: "Mole",
            health: 8,
            moves: [
                Move(
                    name: "Burrow",
                    damage: 3,
                    cost: 2
                )
            ],
            abilities: [
                AbilityData.hardShell
            ]
        ),

        GameCard(
            cardID: .axolotl,
            name: "Axolotl",
            health: 6,
            moves: [
                Move(
                    name: "Snap",
                    damage: 3,
                    cost: 2
                )
            ],
            abilities: [
                AbilityData.regenerate
            ]
        ),

        GameCard(
            cardID: .boar,
            name: "Boar",
            health: 7,
            moves: [
                Move(
                    name: "Ram",
                    damage: 3,
                    cost: 2
                )
            ],
            abilities: [
                AbilityData.spikes
            ]
        ),

        GameCard(
            cardID: .pufferfish,
            name: "Pufferfish",
            health: 5,
            moves: [
                Move(
                    name: "Needles",
                    damage: 4,
                    cost: 2
                )
            ],
            abilities: [
                AbilityData.deathBurst
            ]
        ),

        // MARK: - 3 Cost Ability Cards

        GameCard(
            cardID: .pangolin,
            name: "Pangolin",
            health: 10,
            moves: [
                Move(
                    name: "Slam",
                    damage: 4,
                    cost: 3
                )
            ],
            abilities: [
                AbilityData.hardShell
            ]
        ),

        GameCard(
            cardID: .moose,
            name: "Moose",
            health: 9,
            moves: [
                Move(
                    name: "Rush",
                    damage: 5,
                    cost: 3
                )
            ],
            abilities: [
                AbilityData.regenerate
            ]
        ),

        GameCard(
            cardID: .badger,
            name: "Badger",
            health: 8,
            moves: [
                Move(
                    name: "Frenzy",
                    damage: 5,
                    cost: 3
                )
            ],
            abilities: [
                AbilityData.spikes
            ]
        ),

        GameCard(
            cardID: .scorpion,
            name: "Scorpion",
            health: 7,
            moves: [
                Move(
                    name: "Stinger",
                    damage: 6,
                    cost: 3
                )
            ],
            abilities: [
                AbilityData.deathBurst
            ]
        )
    ]
}
