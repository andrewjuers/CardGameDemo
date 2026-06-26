//
//  ContentView.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/17/26.
//

import SwiftUI

@MainActor
struct ContentView: View {

    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        VStack(spacing: 12) {

            opponentHeader

            gameBoard

            turnButtons

            combatLog

            playerHand
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemGroupedBackground))
        .alert(item: $viewModel.gameResult) { result in
            Alert(
                title: Text(result.title),
                message: Text(result.message),
                dismissButton: .default(
                    Text("New Game"),
                    action: {
                        viewModel.startNewGame()
                    }
                )
            )
        }
    }

    private var opponentHeader: some View {
        VStack(spacing: 8) {
            Text("Opponent")
                .font(.title3)
                .fontWeight(.bold)

            HStack(spacing: 28) {
                Label(
                    "\(viewModel.opponentHand.count)",
                    systemImage: "rectangle.stack"
                )

                Label(
                    "\(viewModel.opponentDeck.count)",
                    systemImage: "square.stack.3d.up"
                )
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack {
                Text(viewModel.turn == 0 ? "Setup" : "Turn \(viewModel.turn)")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                HStack(spacing: 5) {
                    Image(systemName: "bolt.fill")
                    Text("\(viewModel.energy)")
                }
                .font(.title2)
                .fontWeight(.bold)
            }
        }
    }

    private var gameBoard: some View {
        VStack(spacing: 14) {

            boardRow(
                cards: viewModel.opponentBoard,
                isPlayer: false
            )

            Divider()
                .frame(maxWidth: 500)

            boardRow(
                cards: viewModel.playerBoard,
                isPlayer: true
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func boardRow(
        cards: [GameCard],
        isPlayer: Bool
    ) -> some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { index in
                if index < cards.count {
                    let card = cards[index]

                    if isPlayer {
                        Button {
                            viewModel.togglePlayerCard(card)
                        } label: {
                            boardCard(
                                card,
                                isSelected:
                                    viewModel.selectedPlayerCard?.id == card.id
                            )
                        }
                        .buttonStyle(.plain)
                        .popover(
                            isPresented: Binding(
                                get: {
                                    viewModel.selectedPlayerCard?.id == card.id
                                },
                                set: { isShowing in
                                    if !isShowing {
                                        viewModel.selectedPlayerCard = nil
                                    }
                                }
                            ),
                            attachmentAnchor: .rect(.bounds),
                            arrowEdge: .bottom
                        ) {
                            movePopover(for: card)
                                .presentationCompactAdaptation(.popover)
                        }
                    } else {
                        boardCard(
                            card,
                            isSelected: false
                        )
                    }
                } else {
                    emptyBoardSpace
                }
            }
        }
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity)
    }
    
    private func movePopover(
        for card: GameCard
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(card.name)
                .font(.headline)

            Text("Choose a move")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(card.moves) { move in
                HStack(spacing: 6) {
                    Button {
                        viewModel.useMove(move)
                    } label: {
                        HStack(spacing: 8) {
                            Text(move.name)
                                .fontWeight(.semibold)
                                .lineLimit(1)

                            Spacer()

                            HStack(spacing: 3) {
                                Image(systemName: "burst.fill")
                                    .foregroundStyle(.red)

                                Text("\(move.damage)")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)

                            energySymbols(for: move.cost)
                                .font(.subheadline)
                        }
                        .padding(10)
                        .frame(minWidth: 220)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.energy < move.cost)
                    .opacity(viewModel.energy < move.cost ? 0.45 : 1)
                }
            }
            if viewModel.isLeftmostCard(card) &&
                viewModel.playerBoard.count >= 2 {

                Divider()

                Button {
                    viewModel.mergeLeftmostCards()
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.merge")

                        Text("Merge with next card")

                        Spacer()

                        energySymbols(for: 1)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canMergeLeftmostCards)
                .opacity(
                    viewModel.canMergeLeftmostCards ? 1 : 0.45
                )
            }
        }
        .padding()
    }

    private func boardCard(
        _ card: GameCard,
        isSelected: Bool
    ) -> some View {
        VStack(spacing: 7) {

            HStack {
                HStack(spacing: 3) {
                    Image(systemName: "heart.fill")

                    Text("\(card.health)/\(card.maxHealth)")
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(healthColor(for: card))

                Spacer()
            }

            Text(card.name)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 2)

            ForEach(card.moves) { move in
                HStack(spacing: 5) {
                    Text(move.name)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Spacer(minLength: 2)

                    HStack(spacing: 2) {
                        Image(systemName: "burst.fill")
                            .foregroundStyle(.red)

                        Text("\(move.damage)")
                            .fontWeight(.semibold)
                    }

                    energySymbols(for: move.cost)
                }
                .font(.caption2)
            }

            Spacer(minLength: 2)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .frame(height: 145)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    isSelected
                    ? Color.blue.opacity(0.20)
                    : Color(.secondarySystemGroupedBackground)
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected ? Color.blue : Color.blue.opacity(0.55),
                    lineWidth: isSelected ? 3 : 1.5
                )
        }
        .overlay(alignment: .topTrailing) {
            if viewModel.hasPlannedAttack(for: card) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.green)
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
                    .padding(7)
            }
        }
        .scaleEffect(
            viewModel.attackingCardID == card.id
                ? 1.08
                : 1
        )
        .offset(
            y: viewModel.attackingCardID == card.id
                ? -10
                : 0
        )
        .overlay {
            if viewModel.targetedCardID == card.id {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.3))
            }
        }
        .animation(
            .easeInOut(duration: 0.2),
            value: viewModel.attackingCardID
        )
        .animation(
            .easeInOut(duration: 0.2),
            value: viewModel.targetedCardID
        )
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 4,
            y: 2
        )
    }

    private var emptyBoardSpace: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                Color.secondary.opacity(0.45),
                style: StrokeStyle(
                    lineWidth: 1.5,
                    dash: [7]
                )
            )
            .frame(maxWidth: .infinity)
            .frame(height: 145)
            .overlay {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundStyle(.tertiary)
            }
    }

    private var turnButtons: some View {
        HStack {
            Button {
                viewModel.undoTurn()
            } label: {
                Label("Undo", systemImage: "arrow.uturn.backward")
            }
            .buttonStyle(.bordered)

            Spacer()

            Button {
                viewModel.submitTurn()
            } label: {
                Label(
                    viewModel.turn == 0 ? "Start Game" : "Submit Turn",
                    systemImage: "checkmark"
                )
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSubmitTurn)
            .opacity(viewModel.canSubmitTurn ? 1 : 0.45)
        }
    }

    @ViewBuilder
    private var combatLog: some View {
        if !viewModel.lastAttackResults.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                Text("Last Turn")
                    .font(.headline)

                ForEach(viewModel.lastAttackResults) { result in
                    Text(
                        "\(result.attackerName) used \(result.moveName) on \(result.targetName) for \(result.damage)"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
    }

    private var playerHand: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.cardsInHand) { card in
                    Button {
                        viewModel.playCard(card)
                    } label: {
                        handCard(card)
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.canPlayCard)
                    .opacity(viewModel.canPlayCard ? 1 : 0.45)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func handCard(_ card: GameCard) -> some View {
        VStack(spacing: 8) {

            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)

                Text("\(card.health)/\(card.maxHealth)")
                    .fontWeight(.semibold)

                Spacer()
            }
            .font(.caption)

            Text(card.name)
                .font(.headline)
                .fontWeight(.bold)

            Spacer()

            ForEach(card.moves) { move in
                HStack(spacing: 6) {
                    Text(move.name)
                        .font(.caption)
                        .lineLimit(1)

                    Spacer()

                    HStack(spacing: 3) {
                        Image(systemName: "burst.fill")
                            .foregroundStyle(.red)

                        Text("\(move.damage)")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)

                    energySymbols(for: move.cost)
                        .font(.caption)
                }
            }

            Spacer()
        }
        .padding(12)
        .frame(width: 145, height: 175)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.35))
        }
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 4,
            y: 2
        )
    }

    private func healthColor(
        for card: GameCard
    ) -> Color {
        let percentage =
            Double(card.health) / Double(card.maxHealth)

        if percentage <= 0.3 {
            return .red
        } else if percentage <= 0.6 {
            return .orange
        } else {
            return .green
        }
    }
    
    private func energySymbols(for cost: Int) -> some View {
        HStack(spacing: 1) {
            ForEach(0..<cost, id: \.self) { _ in
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.yellow)
            }
        }
    }
}

#Preview {
    ContentView()
}
