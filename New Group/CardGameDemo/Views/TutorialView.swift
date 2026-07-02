//
//  TutorialView.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 7/1/26.
//


import SwiftUI

struct TutorialView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                tutorialSection(
                    title: "Goal",
                    text: "Defeat all of your opponent’s cards before they defeat all of yours."
                )

                tutorialSection(
                    title: "Starting the Game",
                    text: "Each player has a 6-card deck. You begin with 3 cards in hand and choose 1 free card to place on the board."
                )

                tutorialSection(
                    title: "Turns and Energy",
                    text: "Your available energy equals the current turn number. Playing a card costs 1 energy. Each move has its own energy cost."
                )

                tutorialSection(
                    title: "The Board",
                    text: "Each player can have up to 3 cards on the board. Cards attack the opposing card in the same position."
                )
                
                boardExample

                tutorialSection(
                    title: "Using Moves",
                    text: "Tap one of your board cards and choose a move. A card may use multiple different moves in one turn, but each move can only be used once per turn."
                )

                tutorialSection(
                    title: "Merging",
                    text: "Adjacent cards can merge. Their health, moves, and abilities combine. A 2-card merge costs 1 energy. Adding a third card costs 2 energy. A merged card can contain no more than 3 cards."
                )

                tutorialSection(
                    title: "Simultaneous Combat",
                    text: "Both players choose actions before combat resolves. Attacks are based on the board positions at the start of resolution, then defeated cards are removed and the remaining cards shift left."
                )

                tutorialSection(
                    title: "Abilities",
                    text: "Abilities can reduce damage, heal, retaliate, trigger on defeat, protect cards, or affect nearby lanes. Tap an ability badge on a card to read its description."
                )

                tutorialSection(
                    title: "Last Turn Log",
                    text: "The Last Turn Log shows cards played, merges, attacks, abilities, healing, and defeated cards."
                )

                tutorialSection(
                    title: "Winning",
                    text: "You win when your opponent has no cards remaining on the board, in hand, or in their deck."
                )
            }
            .padding()
        }
        .navigationTitle("How to Play")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func tutorialSection(
        title: String,
        text: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)

            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    Color(
                        .secondarySystemGroupedBackground
                    )
                )
        )
    }
    
    private var boardExample: some View {
        VStack(spacing: 12) {
            Text("Opponent")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                tutorialCard(
                    name: "Duck",
                    health: 6,
                    isOpponent: true
                )

                tutorialCard(
                    name: "Goat",
                    health: 6,
                    isOpponent: true
                )

                tutorialCard(
                    name: "Roach",
                    health: 6,
                    isOpponent: true
                )
            }

            HStack(spacing: 10) {
                attackArrow
                attackArrow
                attackArrow
            }

            HStack(spacing: 10) {
                tutorialCard(
                    name: "Dog",
                    health: 7,
                    isOpponent: false
                )

                tutorialCard(
                    name: "Coyote",
                    health: 7,
                    isOpponent: false
                )

                tutorialCard(
                    name: "Octopus",
                    health: 7,
                    isOpponent: false
                )
            }

            Text("Your Board")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Text("Cards normally attack the opposing card in the same lane.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    Color(
                        .secondarySystemGroupedBackground
                    )
                )
        )
    }
    
    private func tutorialCard(
        name: String,
        health: Int,
        isOpponent: Bool
    ) -> some View {
        VStack(spacing: 7) {
            HStack(spacing: 3) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)

                Text("\(health)")
                    .fontWeight(.bold)
            }
            .font(.caption)

            Image(
                systemName: isOpponent
                    ? "pawprint.fill"
                    : "hare.fill"
            )
            .font(.title2)
            .foregroundStyle(
                isOpponent
                    ? Color.orange
                    : Color.blue
            )

            Text(name)
                .font(.caption2)
                .fontWeight(.semibold)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 88)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    Color.secondary.opacity(0.25)
                )
        }
    }
    
    private var attackArrow: some View {
        Image(systemName: "arrow.up.and.down")
            .font(.title3)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        TutorialView()
    }
}
