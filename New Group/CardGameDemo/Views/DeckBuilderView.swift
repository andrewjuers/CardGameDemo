//
//  DeckBuilderView.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/26/26.
//


import SwiftUI

struct DeckBuilderView: View {

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
        ScrollView {
            LazyVGrid(
                columns: columns,
                spacing: 14
            ) {
                ForEach(CardData.allCards) { card in
                    CardView(
                        card: card,
                        isSelected: false,
                        showsQueuedMove: false,
                        width: nil,
                        height: 175,
                        usesCompactMoveLayout: false
                    )
                }
            }
            .padding()
        }
        .background(
            Color(.systemGroupedBackground)
        )
        .navigationTitle("Build Your Deck")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DeckBuilderView()
    }
}
