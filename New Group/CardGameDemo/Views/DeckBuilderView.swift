//
//  DeckBuilderView.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/26/26.
//


import SwiftUI

@MainActor
struct DeckBuilderView: View {
    
    @State private var selectedCardIDs: Set<CardID> = []

    private var selectedCards: [GameCard] {
        CardData.allCards.filter {
            selectedCardIDs.contains($0.cardID)
        }
    }
    
    private let columns = [
        GridItem(
            .flexible(),
            spacing: 12
        ),
        GridItem(
            .flexible(),
            spacing: 12
        )
    ]

    var body: some View {
        VStack {
            HStack {
                Text("Selected")
                
                Spacer()
                
                Text("\(selectedCardIDs.count) / 6")
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
            ScrollView {
                LazyVGrid(
                    columns: columns,
                    spacing: 14
                ) {
                    ForEach(CardData.allCards) { card in
                        CardView(
                            card: card,
                            isSelected: selectedCardIDs.contains(card.cardID),
                            showsQueuedMove: false,
                            width: nil,
                            height: 175,
                            usesCompactMoveLayout: false
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleSelection(for: card)
                        }
                        .opacity(
                            selectedCardIDs.count == 6 &&
                            !selectedCardIDs.contains(card.cardID)
                            ? 0.5
                            : 1
                        )
                    }
                }
                .padding()
            }
            .background(
                Color(.systemGroupedBackground)
            )
            NavigationLink {
                ContentView(
                    viewModel: GameViewModel(
                        customPlayerDeck: selectedCards
                    )
                )
            } label: {
                Text("Start Game")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        selectedCardIDs.count == 6
                        ? Color.blue
                        : Color.gray
                    )
                    .foregroundStyle(.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
            }
            .disabled(selectedCardIDs.count != 6)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Build Your Deck")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleSelection(for card: GameCard) {
        if selectedCardIDs.contains(card.cardID) {
            selectedCardIDs.remove(card.cardID)
            return
        }

        guard selectedCardIDs.count < 6 else {
            return
        }

        selectedCardIDs.insert(card.cardID)
    }
}

#Preview {
    NavigationStack {
        DeckBuilderView()
    }
}
