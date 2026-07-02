//
//  HomeView.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/26/26.
//


import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("Card Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Choose how you want to play")
                    .foregroundStyle(.secondary)

                NavigationLink {
                    ContentView()
                } label: {
                    homeButton(
                        title: "Random Deck",
                        systemImage: "shuffle"
                    )
                }

                NavigationLink {
                    DeckBuilderView()
                } label: {
                    homeButton(
                        title: "Build Your Deck",
                        systemImage: "rectangle.stack.badge.plus"
                    )
                }
                
                NavigationLink {
                    TutorialView()
                } label: {
                    Label(
                        "How to Play",
                        systemImage: "questionmark.circle.fill"
                    )
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Color(.secondarySystemBackground)
                    )
                    .foregroundStyle(.primary)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 14)
                    )
                }

                Spacer()
            }
            .padding()
        }
    }

    private func homeButton(
        title: String,
        systemImage: String
    ) -> some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title2)

            Text(title)
                .font(.headline)

            Spacer()

            Image(systemName: "chevron.right")
        }
        .padding()
        .frame(maxWidth: 350)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.4))
        }
    }
}

#Preview {
    HomeView()
}
