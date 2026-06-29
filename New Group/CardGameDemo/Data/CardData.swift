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
            name: "Deer",
            health: 9,
            moves: [
                Move(
                    name: "Antler Strike",
                    damage: 1,
                    cost: 1
                )
            ]
        ),

        // MARK: - 2 Cost Cards

        GameCard(
            name: "Flamingo",
            health: 8,
            moves: [
                Move(
                    name: "Wing Strike",
                    damage: 5,
                    cost: 2
                )
            ]
        ),

        GameCard(
            name: "Hippo",
            health: 9,
            moves: [
                Move(
                    name: "Heavy Bite",
                    damage: 4,
                    cost: 2
                )
            ]
        ),

        GameCard(
            name: "Beetle",
            health: 6,
            moves: [
                Move(
                    name: "Horn Charge",
                    damage: 6,
                    cost: 2
                )
            ]
        ),

        GameCard(
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
            name: "Turtle",
            health: 11,
            moves: [
                Move(
                    name: "Shell Bash",
                    damage: 3,
                    cost: 2
                )
            ]
        ),

        // MARK: - 3 Cost Cards

        GameCard(
            name: "Lion",
            health: 9,
            moves: [
                Move(
                    name: "Savage Roar",
                    damage: 7,
                    cost: 3
                )
            ]
        ),

        GameCard(
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
            name: "Armadillo",
            health: 7,
            moves: [
                Move(
                    name: "Claw",
                    damage: 1,
                    cost: 1
                )
            ],
            abilities: [
                AbilityData.hardShell
            ]
        ),

        GameCard(
            name: "Salamander",
            health: 5,
            moves: [
                Move(
                    name: "Tail Whip",
                    damage: 2,
                    cost: 1
                )
            ],
            abilities: [
                AbilityData.regenerate
            ]
        ),

        GameCard(
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
            name: "Mole",
            health: 8,
            moves: [
                Move(
                    name: "Burrow Strike",
                    damage: 3,
                    cost: 2
                )
            ],
            abilities: [
                AbilityData.hardShell
            ]
        ),

        GameCard(
            name: "Axolotl",
            health: 6,
            moves: [
                Move(
                    name: "Water Snap",
                    damage: 3,
                    cost: 2
                )
            ],
            abilities: [
                AbilityData.regenerate
            ]
        ),

        GameCard(
            name: "Boar",
            health: 7,
            moves: [
                Move(
                    name: "Tusk Charge",
                    damage: 3,
                    cost: 2
                )
            ],
            abilities: [
                AbilityData.spikes
            ]
        ),

        GameCard(
            name: "Pufferfish",
            health: 5,
            moves: [
                Move(
                    name: "Spine Shot",
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
            name: "Pangolin",
            health: 10,
            moves: [
                Move(
                    name: "Rolling Slam",
                    damage: 4,
                    cost: 3
                )
            ],
            abilities: [
                AbilityData.hardShell
            ]
        ),

        GameCard(
            name: "Moose",
            health: 9,
            moves: [
                Move(
                    name: "Antler Rush",
                    damage: 5,
                    cost: 3
                )
            ],
            abilities: [
                AbilityData.regenerate
            ]
        ),

        GameCard(
            name: "Wolverine",
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
