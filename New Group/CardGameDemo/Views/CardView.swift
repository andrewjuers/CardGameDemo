//
//  CardView.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/26/26.
//


import SwiftUI

struct CardView: View {
    
    @State private var showsAbilityList = false
    
    let card: GameCard
    let isSelected: Bool
    let showsQueuedMove: Bool
    let width: CGFloat?
    let height: CGFloat
    let usesCompactMoveLayout: Bool
    
    var body: some View {
        VStack(spacing: 7) {
            healthRow

            Text(card.name)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )

            abilitySection

            Spacer(minLength: 2)

            moveSection

            Spacer(minLength: 2)
        }
        .padding(10)
        .frame(width: width)
        .frame(maxWidth: width == nil ? .infinity : nil)
        .frame(height: height)
        .background(cardBackground)
        .overlay(cardBorder)
        .overlay(alignment: .topTrailing) {
            queuedMoveIndicator
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 4,
            y: 2
        )
    }

    private var healthRow: some View {
        HStack {
            HStack(spacing: 3) {
                Image(systemName: "heart.fill")

                Text("\(card.health)/\(card.maxHealth)")
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(healthColor)

            Spacer()
        }
    }

    @ViewBuilder
    private var abilitySection: some View {
        if card.abilities.count == 1,
           let ability = card.abilities.first {

            Button {
                showsAbilityList = true
            } label: {
                abilityBadgeLabel(
                    title: ability.name
                )
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showsAbilityList) {
                abilityList
                    .presentationCompactAdaptation(.popover)
            }

        } else if card.abilities.count > 1 {
            Button {
                showsAbilityList = true
            } label: {
                abilityBadgeLabel(
                    title: "Abilities \(card.abilities.count)"
                )
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showsAbilityList) {
                abilityList
                    .presentationCompactAdaptation(.popover)
            }
        }
    }

    private var moveSection: some View {
        VStack(spacing: 5) {
            ForEach(card.moves.prefix(3)) { move in
                HStack(spacing: 4) {
                    Text(move.name)
                        .font(
                            .system(
                                size: usesCompactMoveLayout ? 9 : 11,
                                weight: .medium
                            )
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .truncationMode(.tail)

                    Spacer(minLength: 3)

                    HStack(spacing: 4) {
                        energySymbols(
                            for: move.cost,
                            compact: usesCompactMoveLayout
                        )

                        Text("\(move.damage)")
                            .fontWeight(.semibold)

                        Image(systemName: "burst.fill")
                            .foregroundStyle(.red)
                    }
                    .font(
                        .system(
                            size: usesCompactMoveLayout ? 9 : 11,
                            weight: .semibold
                        )
                    )
                    .fixedSize()
                    .layoutPriority(1)
                }
            }
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                isSelected
                ? Color.blue.opacity(0.20)
                : Color(.secondarySystemGroupedBackground)
            )
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                isSelected
                ? Color.blue
                : Color.blue.opacity(0.55),
                lineWidth: isSelected ? 3 : 1.5
            )
    }

    @ViewBuilder
    private var queuedMoveIndicator: some View {
        if showsQueuedMove {
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

    private var healthColor: Color {
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

    private func energySymbols(
        for cost: Int,
        compact: Bool
    ) -> some View {
        HStack(spacing: compact ? -1 : 1) {
            ForEach(0..<cost, id: \.self) { _ in
                Image(systemName: "bolt.fill")
                    .font(
                        .system(
                            size: compact ? 9 : 11,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.yellow)
            }
        }
        .fixedSize()
    }
    
    private func abilityBadgeLabel(
        title: String
    ) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")

            Text(title)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .font(.caption2)
        .fontWeight(.semibold)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .foregroundStyle(.purple)
        .background(
            Capsule()
                .fill(Color.purple.opacity(0.12))
        )
        .overlay {
            Capsule()
                .stroke(Color.purple.opacity(0.4))
        }
    }
    
    private var abilityList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(card.name)
                    .font(.headline)

                ForEach(card.abilities, id: \.id) { ability in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.purple)

                            Text(ability.name)
                                .fontWeight(.semibold)

                            Spacer()

                            if ability.isOneTime {
                                Text(
                                    card.usedAbilityIDs.contains(ability.id)
                                    ? "Used"
                                    : "Once"
                                )
                                .font(.caption2)
                                .foregroundStyle(
                                    card.usedAbilityIDs.contains(ability.id)
                                    ? Color.secondary
                                    : Color.orange
                                )
                            }
                        }

                        Text(ability.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if ability.id != card.abilities.last?.id {
                        Divider()
                    }
                }
            }
            .padding()
        }
        .frame(width: 280)
        .frame(maxHeight: 350)
    }
}
