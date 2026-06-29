//
//  GameViewModel.swift
//  CardGameDemo
//
//  Created by Andrew   Juers on 6/22/26.
//

import Foundation
import Combine


struct PlannedAttack {
    let attackerID: UUID
    let move: Move
}

struct AttackResult: Identifiable {
    let id = UUID()

    let attackerID: UUID
    let targetID: UUID

    let attackerName: String
    let targetName: String
    let moveName: String

    let damage: Int
    let isPlayerAction: Bool
    let boardPosition: Int
}

enum GameResult: Identifiable {
    case playerWon
    case opponentWon
    case draw

    var id: String {
        switch self {
        case .playerWon:
            return "playerWon"
        case .opponentWon:
            return "opponentWon"
        case .draw:
            return "draw"
        }
    }

    var title: String {
        switch self {
        case .playerWon:
            return "You Win!"
        case .opponentWon:
            return "You Lose"
        case .draw:
            return "Draw"
        }
    }

    var message: String {
        switch self {
        case .playerWon:
            return "The opponent has no cards remaining."
        case .opponentWon:
            return "You have no cards remaining."
        case .draw:
            return "Both players ran out of cards at the same time."
        }
    }
}

@MainActor
final class GameViewModel: ObservableObject {

    @Published var turn = 0
    @Published var energy = 0

    @Published var cardsInHand: [GameCard] = []
    @Published var playerDeck: [GameCard] = []

    @Published var opponentHand: [GameCard] = []
    @Published var opponentDeck: [GameCard] = []

    @Published var playerBoard: [GameCard] = []
    @Published var opponentBoard: [GameCard] = []
    
    @Published var selectedPlayerCard: GameCard?
    
    @Published var plannedPlayerAttacks: [PlannedAttack] = []
    
    @Published var lastAttackResults: [AttackResult] = []
    @Published var lastAbilityMessages: [String] = []
    
    @Published var gameResult: GameResult?
    
    @Published var isResolvingTurn = false
    @Published var hasTakenAction = false
    
    @Published var turnActions: [TurnAction] = []
    @Published var currentAction: TurnAction?
    
    @Published var attackingCardID: UUID?
    @Published var targetedCardID: UUID?
    @Published var newlyPlayedCardID: UUID?
    @Published var mergingCardIDs: Set<UUID> = []
    
    @Published var lastTurnEvents: [TurnEvent] = []

    private var currentTurnEvents: [TurnEvent] = []
    
    private var turnStartHasTakenAction = false

    private var turnStartPlannedAttacks: [PlannedAttack] = []

    private var turnStartHand: [GameCard] = []
    private var turnStartPlayerDeck: [GameCard] = []
    private var turnStartPlayerBoard: [GameCard] = []
    private var turnStartOpponentBoard: [GameCard] = []
    private var turnStartEnergy = 0
    
    private let customPlayerDeck: [GameCard]?

    init(customPlayerDeck: [GameCard]? = nil) {
        self.customPlayerDeck = customPlayerDeck

        setupGame()
        saveTurnStart()
    }
    
    func startNewGame() {
        turn = 0
        energy = 0

        cardsInHand.removeAll()
        playerDeck.removeAll()
        opponentHand.removeAll()
        opponentDeck.removeAll()

        playerBoard.removeAll()
        opponentBoard.removeAll()

        plannedPlayerAttacks.removeAll()
        lastAttackResults.removeAll()

        selectedPlayerCard = nil
        gameResult = nil

        setupGame()
        saveTurnStart()
    }

    func setupGame() {
        let playerCards: [GameCard]

        if let customPlayerDeck {
            playerCards = customPlayerDeck.shuffled()
        } else {
            playerCards = Array(
                CardData.allCards
                    .shuffled()
                    .prefix(6)
            )
        }

        let opponentCards = Array(
            CardData.allCards
                .shuffled()
                .prefix(6)
        )

        cardsInHand = Array(playerCards.prefix(3))
        playerDeck = Array(playerCards.dropFirst(3))

        opponentHand = Array(opponentCards.prefix(3))
        opponentDeck = Array(opponentCards.dropFirst(3))
    }
    
    var canSubmitTurn: Bool {
        if gameResult != nil || isResolvingTurn {
            return false
        }

        if turn == 0 {
            return playerBoard.count == 1
        }

        return hasTakenAction
    }
    
    var canPlayCard: Bool {
        if playerBoard.count == 3 {
            return false
        }

        if turn == 0 {
            return playerBoard.isEmpty
        }

        return energy > 0
    }

    func playCard(_ card: GameCard) {
        guard gameResult == nil else {
            return
        }
        guard playerBoard.count < 3 else {
            return
        }

        var playedCard = card
        playedCard.playedTurn = turn

        if turn == 0 {
            guard playerBoard.isEmpty else {
                return
            }

            playerBoard.append(playedCard)
            cardsInHand.removeAll { $0.id == card.id }
            logEvent(
                type: .cardPlayed,
                message: "You started with \(playedCard.name)"
            )
            return
        }

        guard energy > 0 else {
            return
        }

        playerBoard.append(playedCard)
        cardsInHand.removeAll { $0.id == card.id }
        energy -= 1
        hasTakenAction = true
        logEvent(
            type: .cardPlayed,
            message: "You played \(card.name)"
        )
    }

    func undoTurn() {
        cardsInHand = turnStartHand
        playerDeck = turnStartPlayerDeck
        playerBoard = turnStartPlayerBoard
        energy = turnStartEnergy
        opponentBoard = turnStartOpponentBoard
        plannedPlayerAttacks = turnStartPlannedAttacks
        hasTakenAction = turnStartHasTakenAction
    }

    func submitTurn() {
        guard canSubmitTurn else {
            return
        }

        isResolvingTurn = true

        if turn == 0 {
            guard playerBoard.count == 1 else {
                isResolvingTurn = false
                return
            }

            var setupEnergy = 0

            playOpponentCard(
                using: &setupEnergy,
                isFree: true
            )

            drawPlayerCard()
            drawOpponentCard()

            // Logging initial state
            finishTurnLog()
            
            turn = 1
            energy = 1
            hasTakenAction = false
            isResolvingTurn = false

            saveTurnStart()
            return
        }

        Task {
            var opponentEnergy = turn
            
            if let mergeIndex = OpponentAI.chooseMergeIndex(
                opponentBoard: opponentBoard,
                playerBoard: playerBoard,
                turn: turn,
                energy: opponentEnergy
            ) {
                mergeOpponentCards(
                    at: mergeIndex,
                    using: &opponentEnergy
                )
            }

            playOpponentCard(
                using: &opponentEnergy
            )

            let playerBoardSnapshot = playerBoard
            let opponentBoardSnapshot = opponentBoard

            let opponentAttacks = createOpponentAttacks(
                using: &opponentEnergy
            )

            let results = createAttackResults(
                playerAttacks: plannedPlayerAttacks,
                opponentAttacks: opponentAttacks,
                playerBoardSnapshot: playerBoardSnapshot,
                opponentBoardSnapshot: opponentBoardSnapshot
            )

            lastAttackResults = results
            for result in results {
                logEvent(
                    type: .attack,
                    message: "\(result.attackerName) used \(result.moveName) on \(result.targetName) for \(result.damage) damage"
                )
            }
            turnActions = makeAttackActions(from: results)

            await animateTurnActions()

            resolveCombat(results)
            
            // Logging turn
            finishTurnLog()

            plannedPlayerAttacks.removeAll()
            selectedPlayerCard = nil
            turnActions.removeAll()

            checkForGameOver()

            if gameResult != nil {
                isResolvingTurn = false
                return
            }

            turn += 1
            energy = turn

            drawPlayerCard()
            drawOpponentCard()

            hasTakenAction = false
            isResolvingTurn = false

            saveTurnStart()
        }
    }

    private func saveTurnStart() {
        turnStartHand = cardsInHand
        turnStartPlayerDeck = playerDeck
        turnStartPlayerBoard = playerBoard
        turnStartEnergy = energy
        turnStartOpponentBoard = opponentBoard
        turnStartPlannedAttacks = plannedPlayerAttacks
        turnStartHasTakenAction = hasTakenAction
    }
    
    private func playOpponentCard(
        using energy: inout Int,
        isFree: Bool = false
    ) {
        guard opponentBoard.count < 3 else {
            return
        }

        guard let cardID = OpponentAI.chooseCardToPlay(
            from: opponentHand
        ) else {
            return
        }

        guard let cardIndex = opponentHand.firstIndex(
            where: { $0.id == cardID }
        ) else {
            return
        }

        if !isFree {
            guard energy >= 1 else {
                return
            }

            energy -= 1
        }

        var playedCard = opponentHand.remove(
            at: cardIndex
        )

        playedCard.playedTurn = turn
        opponentBoard.append(playedCard)

        logEvent(
            type: .cardPlayed,
            message: isFree
                ? "Opponent started with \(playedCard.name)"
                : "Opponent played \(playedCard.name)"
        )
    }
    
    private func drawPlayerCard() {
        guard cardsInHand.count < 3 else {
            return
        }

        guard !playerDeck.isEmpty else {
            return
        }

        let drawnCard = playerDeck.removeFirst()
        cardsInHand.append(drawnCard)
    }

    private func drawOpponentCard() {
        guard opponentHand.count < 3 else {
            return
        }

        guard !opponentDeck.isEmpty else {
            return
        }

        let drawnCard = opponentDeck.removeFirst()
        opponentHand.append(drawnCard)
    }
    
    func togglePlayerCard(_ card: GameCard) {
        if selectedPlayerCard?.id == card.id {
            selectedPlayerCard = nil
        } else {
            selectedPlayerCard = card
        }
    }
    
    func plannedMoveCount(
        for card: GameCard,
        move: Move
    ) -> Int {
        plannedPlayerAttacks.filter {
            $0.attackerID == card.id &&
            $0.move.id == move.id
        }
        .count
    }

    func hasPlannedAttack(
        for card: GameCard
    ) -> Bool {
        plannedPlayerAttacks.contains {
            $0.attackerID == card.id
        }
    }

    func useMove(_ move: Move) {
        guard gameResult == nil else {
            return
        }
        guard energy >= move.cost else {
            return
        }

        guard let selectedCard = selectedPlayerCard else {
            return
        }

        guard playerBoard.contains(
            where: { $0.id == selectedCard.id }
        ) else {
            return
        }

        let plannedAttack = PlannedAttack(
            attackerID: selectedCard.id,
            move: move
        )

        plannedPlayerAttacks.append(plannedAttack)
        energy -= move.cost
        hasTakenAction = true
    }
    
    private func createOpponentAttacks(
        using energy: inout Int
    ) -> [PlannedAttack] {
        let attacks = OpponentAI.chooseAttacks(
            from: opponentBoard,
            against: playerBoard,
            using: energy
        )

        let totalCost = attacks.reduce(0) {
            $0 + $1.move.cost
        }

        energy -= totalCost

        return attacks
    }
    
    private func createAttackResults(
        playerAttacks: [PlannedAttack],
        opponentAttacks: [PlannedAttack],
        playerBoardSnapshot: [GameCard],
        opponentBoardSnapshot: [GameCard]
    ) -> [AttackResult] {

        var results: [AttackResult] = []

        for attack in playerAttacks {
            guard let attackerPosition = playerBoardSnapshot.firstIndex(
                where: { $0.id == attack.attackerID }
            ) else {
                continue
            }

            guard opponentBoardSnapshot.indices.contains(attackerPosition) else {
                continue
            }

            let target = opponentBoardSnapshot[attackerPosition]

            let attacker = playerBoardSnapshot[attackerPosition]

            results.append(
                AttackResult(
                    attackerID: attacker.id,
                    targetID: target.id,
                    attackerName: attacker.name,
                    targetName: target.name,
                    moveName: attack.move.name,
                    damage: attack.move.damage,
                    isPlayerAction: true,
                    boardPosition: attackerPosition
                )
            )
        }

        for attack in opponentAttacks {
            guard let attackerPosition = opponentBoardSnapshot.firstIndex(
                where: { $0.id == attack.attackerID }
            ) else {
                continue
            }

            guard playerBoardSnapshot.indices.contains(attackerPosition) else {
                continue
            }

            let target = playerBoardSnapshot[attackerPosition]

            let attacker = opponentBoardSnapshot[attackerPosition]

            results.append(
                AttackResult(
                    attackerID: attacker.id,
                    targetID: target.id,
                    attackerName: attacker.name,
                    targetName: target.name,
                    moveName: attack.move.name,
                    damage: attack.move.damage,
                    isPlayerAction: false,
                    boardPosition: attackerPosition
                )
            )
        }

        return results
    }
    
    private func applyAttackResults(
        _ results: [AttackResult]
    ) {
        var totalDamage: [UUID: Int] = [:]

        for result in results {
            if let target = playerBoard.first(
                where: { $0.id == result.targetID }
            ) {
                let adjustedDamage =
                    AbilityResolver.adjustedAttackDamage(
                        result.damage,
                        against: target
                    )

                let blockedDamage = result.damage - adjustedDamage

                if blockedDamage > 0 {
                    logAbility(
                        cardName: target.name,
                        abilityName: "Hard Shell",
                        message: "blocked \(blockedDamage) damage"
                    )
                }

                totalDamage[result.targetID, default: 0] += adjustedDamage
            } else if let target = opponentBoard.first(
                where: { $0.id == result.targetID }
            ) {
                let adjustedDamage =
                    AbilityResolver.adjustedAttackDamage(
                        result.damage,
                        against: target
                    )

                totalDamage[result.targetID, default: 0] += adjustedDamage
            }
        }

        for index in playerBoard.indices {
            let cardID = playerBoard[index].id
            playerBoard[index].health -= totalDamage[cardID, default: 0]
        }

        for index in opponentBoard.indices {
            let cardID = opponentBoard[index].id
            opponentBoard[index].health -= totalDamage[cardID, default: 0]
        }

        if let selectedPlayerCard,
           !playerBoard.contains(where: {
               $0.id == selectedPlayerCard.id
           }) {
            self.selectedPlayerCard = nil
        }
    }
    
    func canMergeCards(
        at leftIndex: Int
    ) -> Bool {
        let rightIndex = leftIndex + 1

        guard playerBoard.indices.contains(leftIndex),
              playerBoard.indices.contains(rightIndex) else {
            return false
        }

        guard energy >= 1 else {
            return false
        }

        let leftCard = playerBoard[leftIndex]
        let rightCard = playerBoard[rightIndex]

        guard let leftPlayedTurn = leftCard.playedTurn,
              let rightPlayedTurn = rightCard.playedTurn else {
            return false
        }

        guard leftPlayedTurn < turn,
              rightPlayedTurn < turn else {
            return false
        }

        guard leftCard.componentCount +
                rightCard.componentCount <= 3 else {
            return false
        }

        let leftHasPlannedMove = plannedPlayerAttacks.contains {
            $0.attackerID == leftCard.id
        }

        let rightHasPlannedMove = plannedPlayerAttacks.contains {
            $0.attackerID == rightCard.id
        }

        return !leftHasPlannedMove &&
               !rightHasPlannedMove
    }
    
    func mergeCards(
        at leftIndex: Int
    ) {
        guard canMergeCards(at: leftIndex) else {
            return
        }

        let rightIndex = leftIndex + 1

        let leftCard = playerBoard[leftIndex]
        let rightCard = playerBoard[rightIndex]

        let combinedMoves = uniqueMoves(
            leftCard.moves + rightCard.moves
        )

        let combinedAbilities =
            leftCard.abilities + rightCard.abilities

        let combinedUsedAbilityIDs =
            leftCard.usedAbilityIDs.union(
                rightCard.usedAbilityIDs
            )

        let mergedCard = GameCard(
            cardID: .merged,
            name: "\(leftCard.name) + \(rightCard.name)",
            health: leftCard.health + rightCard.health,
            maxHealth:
                leftCard.maxHealth + rightCard.maxHealth,
            moves: combinedMoves,
            abilities: combinedAbilities,
            componentCount:
                leftCard.componentCount +
                rightCard.componentCount,
            playedTurn: turn,
            usedAbilityIDs: combinedUsedAbilityIDs
        )

        playerBoard[leftIndex] = mergedCard
        playerBoard.remove(at: rightIndex)

        energy -= 1
        hasTakenAction = true
        selectedPlayerCard = mergedCard
        logEvent(
            type: .merge,
            message: "You merged \(leftCard.name) with \(rightCard.name)"
        )
    }
    
    private func canOpponentMergeCards(
        at leftIndex: Int,
        energy: Int
    ) -> Bool {
        let rightIndex = leftIndex + 1

        guard opponentBoard.indices.contains(leftIndex),
              opponentBoard.indices.contains(rightIndex) else {
            return false
        }

        guard energy >= 1 else {
            return false
        }

        let leftCard = opponentBoard[leftIndex]
        let rightCard = opponentBoard[rightIndex]

        guard let leftPlayedTurn = leftCard.playedTurn,
              let rightPlayedTurn = rightCard.playedTurn else {
            return false
        }

        guard leftPlayedTurn < turn,
              rightPlayedTurn < turn else {
            return false
        }

        return leftCard.componentCount +
            rightCard.componentCount <= 3
    }
    
    private func mergeOpponentCards(
        at leftIndex: Int,
        using energy: inout Int
    ) {
        guard canOpponentMergeCards(
            at: leftIndex,
            energy: energy
        ) else {
            return
        }

        let rightIndex = leftIndex + 1

        let leftCard = opponentBoard[leftIndex]
        let rightCard = opponentBoard[rightIndex]

        let combinedMoves = uniqueMoves(
            leftCard.moves + rightCard.moves
        )

        let combinedAbilities =
            leftCard.abilities + rightCard.abilities

        let combinedUsedAbilityIDs =
            leftCard.usedAbilityIDs.union(
                rightCard.usedAbilityIDs
            )

        let mergedCard = GameCard(
            cardID: .merged,
            name: "\(leftCard.name) + \(rightCard.name)",
            health: leftCard.health + rightCard.health,
            maxHealth:
                leftCard.maxHealth + rightCard.maxHealth,
            moves: combinedMoves,
            abilities: combinedAbilities,
            componentCount:
                leftCard.componentCount +
                rightCard.componentCount,
            playedTurn: turn,
            usedAbilityIDs: combinedUsedAbilityIDs
        )

        opponentBoard[leftIndex] = mergedCard
        opponentBoard.remove(at: rightIndex)

        energy -= 1

        logEvent(
            type: .merge,
            message: "Opponent merged \(leftCard.name) with \(rightCard.name)"
        )
    }
    
    func playerBoardIndex(
        for card: GameCard
    ) -> Int? {
        playerBoard.firstIndex {
            $0.id == card.id
        }
    }
    
    private func uniqueMoves(
        _ moves: [Move]
    ) -> [Move] {
        var result: [Move] = []

        for move in moves {
            let alreadyExists = result.contains {
                $0.name == move.name &&
                $0.damage == move.damage &&
                $0.cost == move.cost
            }

            if !alreadyExists {
                result.append(move)
            }
        }

        return result
    }
    
    private func checkForGameOver() {
        let playerHasNoCards =
            playerBoard.isEmpty &&
            cardsInHand.isEmpty &&
            playerDeck.isEmpty

        let opponentHasNoCards =
            opponentBoard.isEmpty &&
            opponentHand.isEmpty &&
            opponentDeck.isEmpty

        if playerHasNoCards && opponentHasNoCards {
            gameResult = .draw
        } else if opponentHasNoCards {
            gameResult = .playerWon
        } else if playerHasNoCards {
            gameResult = .opponentWon
        }
    }
    
    private func animateTurnActions() async {
        for action in turnActions {
            currentAction = action

            attackingCardID = action.actorID
            targetedCardID = action.targetID

            try? await Task.sleep(
                nanoseconds: 650_000_000
            )

            attackingCardID = nil
            targetedCardID = nil

            try? await Task.sleep(
                nanoseconds: 150_000_000
            )
        }

        currentAction = nil
    }
    
    private func makeAttackActions(
        from results: [AttackResult]
    ) -> [TurnAction] {
        results
            .sorted {
                if $0.boardPosition == $1.boardPosition {
                    return $0.isPlayerAction && !$1.isPlayerAction
                }

                return $0.boardPosition < $1.boardPosition
            }
            .map { result in
                TurnAction(
                    type: .attack,
                    actorID: result.attackerID,
                    targetID: result.targetID,
                    actorName: result.attackerName,
                    targetName: result.targetName,
                    moveName: result.moveName,
                    damage: result.damage,
                    isPlayerAction: result.isPlayerAction,
                    boardPosition: result.boardPosition
                )
            }
    }
    
    private func logAbility(
        cardName: String,
        abilityName: String,
        message: String
    ) {
        let fullMessage =
            "\(cardName)'s \(abilityName) \(message)"

        lastAbilityMessages.append(fullMessage)

        logEvent(
            type: .ability,
            message: fullMessage
        )
    }
    
    private func resolveCombat(
        _ results: [AttackResult]
    ) {
        applyAttackResults(results)
        applySpikes(results)
        applyDeathBurst()
        removeDefeatedCards()
        applyEndTurnHealing()
    }
    
    private func applyEndTurnHealing() {
        for index in playerBoard.indices {
            let healing = AbilityResolver.endTurnHealing(
                for: playerBoard[index]
            )

            let oldHealth = playerBoard[index].health

            playerBoard[index].health = min(
                playerBoard[index].health + healing,
                playerBoard[index].maxHealth
            )

            let actualHealing =
                playerBoard[index].health - oldHealth

            if actualHealing > 0 {
                logAbility(
                    cardName: playerBoard[index].name,
                    abilityName: "Regenerate",
                    message: "healed \(actualHealing) health"
                )
            }
        }

        for index in opponentBoard.indices {
            let healing = AbilityResolver.endTurnHealing(
                for: opponentBoard[index]
            )

            let oldHealth = opponentBoard[index].health

            opponentBoard[index].health = min(
                opponentBoard[index].health + healing,
                opponentBoard[index].maxHealth
            )

            let actualHealing =
                opponentBoard[index].health - oldHealth

            if actualHealing > 0 {
                logAbility(
                    cardName: opponentBoard[index].name,
                    abilityName: "Regenerate",
                    message: "healed \(actualHealing) health"
                )
            }
        }
    }
    
    private func applySpikes(
        _ results: [AttackResult]
    ) {
        var retaliationDamage: [UUID: Int] = [:]

        for result in results {
            guard let defender =
                    playerBoard.first(where: {
                        $0.id == result.targetID
                    })
                    ??
                    opponentBoard.first(where: {
                        $0.id == result.targetID
                    }) else {
                continue
            }

            let damage = AbilityResolver.retaliationDamage(
                from: defender
            )

            guard damage > 0 else {
                continue
            }

            retaliationDamage[result.attackerID, default: 0] += damage

            logAbility(
                cardName: defender.name,
                abilityName: "Spikes",
                message: "dealt \(damage) damage to \(result.attackerName)"
            )
        }

        for index in playerBoard.indices {
            playerBoard[index].health -=
                retaliationDamage[playerBoard[index].id, default: 0]
        }

        for index in opponentBoard.indices {
            opponentBoard[index].health -=
                retaliationDamage[opponentBoard[index].id, default: 0]
        }
    }
    
    private func applyDeathBurst() {
        let playerSnapshot = playerBoard
        let opponentSnapshot = opponentBoard

        var damageToPlayerCards: [UUID: Int] = [:]
        var damageToOpponentCards: [UUID: Int] = [:]

        for (index, card) in playerSnapshot.enumerated() {
            guard card.health <= 0 else {
                continue
            }

            let burstDamage = AbilityResolver.defeatDamage(
                from: card
            )

            guard burstDamage > 0 else {
                continue
            }

            guard opponentSnapshot.indices.contains(index) else {
                continue
            }

            let target = opponentSnapshot[index]

            damageToOpponentCards[target.id, default: 0] += burstDamage
        }

        for (index, card) in opponentSnapshot.enumerated() {
            guard card.health <= 0 else {
                continue
            }

            let burstDamage = AbilityResolver.defeatDamage(
                from: card
            )

            guard burstDamage > 0 else {
                continue
            }

            guard playerSnapshot.indices.contains(index) else {
                continue
            }

            let target = playerSnapshot[index]

            damageToPlayerCards[target.id, default: 0] += burstDamage
        }

        for index in playerBoard.indices {
            let cardID = playerBoard[index].id
            playerBoard[index].health -=
                damageToPlayerCards[cardID, default: 0]
        }

        for index in opponentBoard.indices {
            let cardID = opponentBoard[index].id
            opponentBoard[index].health -=
                damageToOpponentCards[cardID, default: 0]
        }
    }
    
    private func removeDefeatedCards() {
        let defeatedPlayerCards = playerBoard.filter {
            $0.health <= 0
        }

        let defeatedOpponentCards = opponentBoard.filter {
            $0.health <= 0
        }

        for card in defeatedPlayerCards {
            logEvent(
                type: .cardDefeated,
                message: "Your \(card.name) was defeated"
            )
        }

        for card in defeatedOpponentCards {
            logEvent(
                type: .cardDefeated,
                message: "Opponent's \(card.name) was defeated"
            )
        }

        playerBoard.removeAll {
            $0.health <= 0
        }

        opponentBoard.removeAll {
            $0.health <= 0
        }

        if let selectedPlayerCard,
           !playerBoard.contains(where: {
               $0.id == selectedPlayerCard.id
           }) {
            self.selectedPlayerCard = nil
        }
    }
    
    private func logEvent(
        type: TurnEventType,
        message: String
    ) {
        currentTurnEvents.append(
            TurnEvent(
                type: type,
                message: message
            )
        )
    }
    
    private func finishTurnLog() {
        lastTurnEvents = currentTurnEvents
        currentTurnEvents.removeAll()
    }
}
