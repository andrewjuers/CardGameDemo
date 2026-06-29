//
//  ContentView.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/17/26.
//

import SwiftUI

@MainActor
struct ContentView: View {

    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    init() {
        _viewModel = StateObject(
            wrappedValue: GameViewModel()
        )
    }

    init(viewModel: GameViewModel) {
        _viewModel = StateObject(
            wrappedValue: viewModel
        )
    }
    
    var body: some View {
        VStack(spacing: 10) {
            lastTurnLog

            turnStatus

            gameBoard

            turnButtons

            playerHand
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(Color(.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top, spacing: 0) {
            topHeader
        }
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
    
    private var topHeader: some View {
        ZStack {
            VStack(spacing: 4) {
                Text("Opponent")
                    .font(.title3)
                    .fontWeight(.bold)

                HStack(spacing: 26) {
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
            }

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Color(.systemGroupedBackground)
        )
    }

    private var opponentHeader: some View {
        VStack(spacing: 6) {
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
        }
        .frame(maxWidth: .infinity)
    }
    
    private var turnStatus: some View {
        HStack {
            Text(
                viewModel.turn == 0
                ? "Setup"
                : "Turn \(viewModel.turn)"
            )
            .font(.title2)
            .fontWeight(.bold)

            Spacer()

            HStack(spacing: 4) {
                ForEach(
                    0..<viewModel.energy,
                    id: \.self
                ) { _ in
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(.yellow)
                }

                if viewModel.energy == 0 {
                    Text("0")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.title3)
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
                        boardCard(
                            card,
                            isSelected:
                                viewModel.selectedPlayerCard?.id == card.id
                        )
                        .onTapGesture {
                            viewModel.togglePlayerCard(card)
                        }
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
            if let cardIndex =
                viewModel.playerBoardIndex(for: card) {

                if cardIndex < viewModel.playerBoard.count - 1 {
                    Divider()

                    Button {
                        viewModel.mergeCards(
                            at: cardIndex
                        )
                    } label: {
                        HStack {
                            Image(
                                systemName:
                                    "arrow.triangle.merge"
                            )

                            Text("Merge with next card")

                            Spacer()

                            energySymbols(for: 1)
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 12
                            )
                            .fill(
                                Color.purple.opacity(0.12)
                            )
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(
                        !viewModel.canMergeCards(
                            at: cardIndex
                        )
                    )
                    .opacity(
                        viewModel.canMergeCards(
                            at: cardIndex
                        )
                        ? 1
                        : 0.45
                    )
                }
            }
        }
        .padding()
    }

    private func boardCard(
        _ card: GameCard,
        isSelected: Bool
    ) -> some View {
        CardView(
            card: card,
            isSelected: isSelected,
            showsQueuedMove: viewModel.hasPlannedAttack(for: card),
            width: nil,
            height: 145,
            usesCompactMoveLayout: true
        )
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

    private var lastTurnLog: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Last Turn")
                .font(.headline)

            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {
                    if viewModel.lastTurnEvents.isEmpty {
                        Text("No actions yet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                    } else {
                        ForEach(viewModel.lastTurnEvents) { event in
                            HStack(alignment: .top, spacing: 6) {
                                Image(
                                    systemName: iconName(
                                        for: event.type
                                    )
                                )
                                .frame(width: 16)

                                Text(event.message)
                                    .font(.caption)
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.visible)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    Color(
                        .secondarySystemGroupedBackground
                    )
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    Color.secondary.opacity(0.2)
                )
        }
    }

    private var playerHand: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.cardsInHand) { card in
                    handCard(card)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if viewModel.canPlayCard {
                                viewModel.playCard(card)
                            }
                        }
                        .opacity(viewModel.canPlayCard ? 1 : 0.45)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func handCard(
        _ card: GameCard
    ) -> some View {
        CardView(
            card: card,
            isSelected: false,
            showsQueuedMove: viewModel.hasPlannedAttack(for: card),
            width: 115,
            height: 145,
            usesCompactMoveLayout: false
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
    
    private func iconName(
        for type: TurnEventType
    ) -> String {
        switch type {
        case .cardPlayed:
            return "rectangle.stack.fill"

        case .attack:
            return "burst.fill"

        case .ability:
            return "sparkles"

        case .merge:
            return "arrow.triangle.merge"

        case .cardDefeated:
            return "xmark.circle.fill"

        case .healing:
            return "cross.fill"
        }
    }
}

#Preview {
    ContentView()
}
