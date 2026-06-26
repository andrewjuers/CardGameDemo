//
//  TurnAction.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/25/26.
//


import Foundation

enum TurnActionType {
    case playCard
    case attack
    case merge
}

struct TurnAction: Identifiable {
    let id = UUID()

    let type: TurnActionType
    let actorID: UUID?
    let targetID: UUID?

    let actorName: String
    let targetName: String?

    let moveName: String?
    let damage: Int?

    let isPlayerAction: Bool
    let boardPosition: Int
}
