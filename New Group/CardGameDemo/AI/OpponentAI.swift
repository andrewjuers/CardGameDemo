//
//  OpponentAI.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/29/26.
//


import Foundation


private struct AttackCandidate {
    let attackerID: UUID
    let move: Move
    let score: Int
}

private struct UsedMoveKey: Hashable {
    let attackerID: UUID
    let moveID: UUID
}

struct OpponentAI {

    static func chooseCardToPlay(
        from hand: [GameCard]
    ) -> UUID? {
        hand.randomElement()?.id
    }

    static func chooseAttacks(
        from opponentBoard: [GameCard],
        against playerBoard: [GameCard],
        using energy: Int
    ) -> [PlannedAttack] {
        var remainingEnergy = energy
        var attacks: [PlannedAttack] = []
        var usedMoves: Set<UsedMoveKey> = []

        var candidates: [AttackCandidate] = []

        for (position, attacker) in opponentBoard.enumerated() {
            guard playerBoard.indices.contains(position) else {
                continue
            }

            let target = playerBoard[position]

            for move in attacker.moves {
                guard move.cost <= energy else {
                    continue
                }

                candidates.append(
                    AttackCandidate(
                        attackerID: attacker.id,
                        move: move,
                        score: scoreMove(
                            move,
                            against: target
                        )
                    )
                )
            }
        }

        candidates.sort {
            $0.score > $1.score
        }

        for candidate in candidates {
            let moveKey = UsedMoveKey(
                attackerID: candidate.attackerID,
                moveID: candidate.move.id
            )

            guard !usedMoves.contains(moveKey) else {
                continue
            }

            guard remainingEnergy >= candidate.move.cost else {
                continue
            }

            attacks.append(
                PlannedAttack(
                    attackerID: candidate.attackerID,
                    move: candidate.move
                )
            )

            usedMoves.insert(moveKey)
            remainingEnergy -= candidate.move.cost
        }

        return attacks
    }
    
    private static func scoreMove(
        _ move: Move,
        against target: GameCard
    ) -> Int {
        var score = 0

        let damage = move.damage
        let overkill = max(
            damage - target.health,
            0
        )

        if damage >= target.health {
            score += 100
        }

        score += damage * 10
        score += damage * 5 / max(move.cost, 1)
        score -= overkill * 4
        score -= move.cost
           
        return score
    }
    
    static func chooseMergeIndex(
        opponentBoard: [GameCard],
        playerBoard: [GameCard],
        turn: Int,
        energy: Int
    ) -> Int? {
        guard energy >= 1 else {
            return nil
        }

        var bestIndex: Int?
        var bestScore = 0

        for leftIndex in 0..<2 {
            let rightIndex = leftIndex + 1

            guard opponentBoard.indices.contains(leftIndex),
                  opponentBoard.indices.contains(rightIndex) else {
                continue
            }

            let leftCard = opponentBoard[leftIndex]
            let rightCard = opponentBoard[rightIndex]

            guard let leftPlayedTurn = leftCard.playedTurn,
                  let rightPlayedTurn = rightCard.playedTurn else {
                continue
            }

            guard leftPlayedTurn < turn,
                  rightPlayedTurn < turn else {
                continue
            }

            guard leftCard.componentCount +
                    rightCard.componentCount <= 3 else {
                continue
            }
            
            let mergeCost =
                leftCard.componentCount +
                rightCard.componentCount - 1

            guard leftCard.componentCount +
                    rightCard.componentCount <= 3 else {
                continue
            }

            guard energy >= mergeCost else {
                continue
            }

            let leftThreat = estimatedIncomingDamage(
                at: leftIndex,
                from: playerBoard,
                turn: turn
            )

            let rightThreat = estimatedIncomingDamage(
                at: rightIndex,
                from: playerBoard,
                turn: turn
            )

            var score = 0

            if leftThreat >= leftCard.health {
                score += 100
            }

            if rightThreat >= rightCard.health {
                score += 100
            }

            score += leftThreat + rightThreat

            if score > bestScore {
                bestScore = score
                bestIndex = leftIndex
            }
        }

        guard bestScore >= 100 else {
            return nil
        }

        return bestIndex
    }
    
    private static func estimatedIncomingDamage(
        at position: Int,
        from playerBoard: [GameCard],
        turn: Int
    ) -> Int {
        guard playerBoard.indices.contains(position) else {
            return 0
        }

        let opposingCard = playerBoard[position]

        return opposingCard.moves
            .filter { $0.cost <= turn }
            .map(\.damage)
            .max() ?? 0
    }
}
