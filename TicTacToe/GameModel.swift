import Foundation

/// Which player's turn it is
enum Player: Equatable {
    case x, o

    /// After X goes, it's O's turn, and vice versa
    var next: Player { self == .x ? .o : .x }

    /// The symbol to draw on‐screen
    var symbol: String { self == .x ? "X" : "O" }
}

/// Bot difficulty levels
enum BotDifficulty: String, CaseIterable {
    case easy = "Easy"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

/// A 3×3 board of optional Player marks
struct Board {
    var cells: [Player?] = Array(repeating: nil, count: 9)
    
    /// Check if a cell is empty
    func isEmpty(at index: Int) -> Bool {
        return cells[index] == nil
    }
    
    /// Get all empty cell indices
    var emptyCells: [Int] {
        return cells.enumerated().compactMap { index, cell in
            cell == nil ? index : nil
        }
    }
    
    /// Check if a move would result in a win for the given player
    func wouldWin(for player: Player, at index: Int) -> Bool {
        var testBoard = self
        testBoard.cells[index] = player
        return testBoard.hasWinner(player)
    }
    
    /// Check if the given player has won
    func hasWinner(_ player: Player) -> Bool {
        let lines = [
            [0,1,2], [3,4,5], [6,7,8],
            [0,3,6], [1,4,7], [2,5,8],
            [0,4,8], [2,4,6],
        ]
        for line in lines {
            if cells[line[0]] == player,
               cells[line[1]] == player,
               cells[line[2]] == player {
                return true
            }
        }
        return false
    }
    
    /// Get the opponent of the given player
    func opponent(of player: Player) -> Player {
        return player == .x ? .o : .x
    }
}

/// Holds the game state, enforces rules, and publishes changes to the UI
@MainActor
class GameState: ObservableObject {
    @Published var board = Board()
    @Published var currentPlayer: Player = .x
    @Published var gameOver = false
    @Published var winner: Player? = nil
    @Published var isBotEnabled = false
    @Published var botDifficulty: BotDifficulty = .intermediate
    @Published var botPlayer: Player = .o

    /// Reset the board back to an empty game
    func reset() {
        board = Board()
        currentPlayer = .x
        gameOver = false
        winner = nil
        
        // If bot is enabled and bot plays as X, make the first move
        if isBotEnabled && botPlayer == .x {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.makeBotMove()
            }
        }
    }
    
    /// Enable bot and reset game
    func enableBot() {
        isBotEnabled = true
        reset()
    }

    /// Attempt to place the current player's mark at `index` (0…8)
    func makeMove(at index: Int) {
        guard !gameOver,
              index >= 0, index < 9,
              board.cells[index] == nil
        else { return }
        
        board.cells[index] = currentPlayer
        checkWin()
        
        if !gameOver {
            currentPlayer = currentPlayer.next
            
            // If bot is enabled and it's the bot's turn, make bot move
            if isBotEnabled && currentPlayer == botPlayer && !gameOver {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.makeBotMove()
                }
            }
        }
    }
    
    /// Make a bot move based on the selected difficulty
    func makeBotMove() {
        guard !gameOver && currentPlayer == botPlayer else { return }
        
        let move: Int
        
        switch botDifficulty {
        case .easy:
            move = makeEasyMove()
        case .intermediate:
            move = makeIntermediateMove()
        case .advanced:
            move = makeAdvancedMove()
        }
        
        if move >= 0 && move < 9 && board.cells[move] == nil {
            board.cells[move] = currentPlayer
            checkWin()
            if !gameOver {
                currentPlayer = currentPlayer.next
            }
        }
    }
    
    /// Easy bot: Random moves
    private func makeEasyMove() -> Int {
        let emptyCells = board.emptyCells
        return emptyCells.randomElement() ?? 0
    }
    
    /// Intermediate bot: Blocks wins and takes wins, otherwise random
    private func makeIntermediateMove() -> Int {
        let emptyCells = board.emptyCells
        
        // First, try to win
        for cell in emptyCells {
            if board.wouldWin(for: botPlayer, at: cell) {
                return cell
            }
        }
        
        // Then, block opponent's win
        let opponent = board.opponent(of: botPlayer)
        for cell in emptyCells {
            if board.wouldWin(for: opponent, at: cell) {
                return cell
            }
        }
        
        // Otherwise, random move
        return emptyCells.randomElement() ?? 0
    }
    
    /// Advanced bot: Uses minimax algorithm for optimal play
    private func makeAdvancedMove() -> Int {
        let emptyCells = board.emptyCells
        
        // First, try to win
        for cell in emptyCells {
            if board.wouldWin(for: botPlayer, at: cell) {
                return cell
            }
        }
        
        // Then, block opponent's win
        let opponent = board.opponent(of: botPlayer)
        for cell in emptyCells {
            if board.wouldWin(for: opponent, at: cell) {
                return cell
            }
        }
        
        // Use minimax for optimal move
        var bestScore = Int.min
        var bestMove = emptyCells[0]
        
        for cell in emptyCells {
            var testBoard = board
            testBoard.cells[cell] = botPlayer
            let score = minimax(board: testBoard, depth: 0, isMaximizing: false, alpha: Int.min, beta: Int.max)
            if score > bestScore {
                bestScore = score
                bestMove = cell
            }
        }
        
        return bestMove
    }
    
    /// Minimax algorithm with alpha-beta pruning
    private func minimax(board: Board, depth: Int, isMaximizing: Bool, alpha: Int, beta: Int) -> Int {
        let emptyCells = board.emptyCells
        
        // Terminal conditions
        if board.hasWinner(botPlayer) {
            return 10 - depth
        }
        if board.hasWinner(board.opponent(of: botPlayer)) {
            return depth - 10
        }
        if emptyCells.isEmpty {
            return 0
        }
        
        var alpha = alpha
        var beta = beta
        
        if isMaximizing {
            var bestScore = Int.min
            for cell in emptyCells {
                var testBoard = board
                testBoard.cells[cell] = botPlayer
                let score = minimax(board: testBoard, depth: depth + 1, isMaximizing: false, alpha: alpha, beta: beta)
                bestScore = max(bestScore, score)
                alpha = max(alpha, score)
                if beta <= alpha {
                    break
                }
            }
            return bestScore
        } else {
            var bestScore = Int.max
            for cell in emptyCells {
                var testBoard = board
                testBoard.cells[cell] = board.opponent(of: botPlayer)
                let score = minimax(board: testBoard, depth: depth + 1, isMaximizing: true, alpha: alpha, beta: beta)
                bestScore = min(bestScore, score)
                beta = min(beta, score)
                if beta <= alpha {
                    break
                }
            }
            return bestScore
        }
    }

    /// Check all win‐lines and draws, update `gameOver` and `winner`
    func checkWin() {
        let lines = [
            [0,1,2], [3,4,5], [6,7,8],
            [0,3,6], [1,4,7], [2,5,8],
            [0,4,8], [2,4,6],
        ]
        for line in lines {
            if let p = board.cells[line[0]],
               board.cells[line[1]] == p,
               board.cells[line[2]] == p
            {
                winner = p
                gameOver = true
                return
            }
        }
        // If no empty cells and no winner, it's a draw
        if !board.cells.contains(where: { $0 == nil }) {
            winner = nil
            gameOver = true
        }
    }
}
