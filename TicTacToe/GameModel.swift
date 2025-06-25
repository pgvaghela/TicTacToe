import Foundation

/// Which player’s turn it is
enum Player: Equatable {
    case x, o

    /// After X goes, it’s O’s turn, and vice versa
    var next: Player { self == .x ? .o : .x }

    /// The symbol to draw on‐screen
    var symbol: String { self == .x ? "X" : "O" }
}

/// A 3×3 board of optional Player marks
struct Board {
    var cells: [Player?] = Array(repeating: nil, count: 9)
}

/// Holds the game state, enforces rules, and publishes changes to the UI
@MainActor
class GameState: ObservableObject {
    @Published var board = Board()
    @Published var currentPlayer: Player = .x
    @Published var gameOver = false
    @Published var winner: Player? = nil

    /// Reset the board back to an empty game
    func reset() {
        board = Board()
        currentPlayer = .x
        gameOver = false
        winner = nil
    }

    /// Attempt to place the current player’s mark at `index` (0…8)
    func makeMove(at index: Int) {
        guard !gameOver,
              index >= 0, index < 9,
              board.cells[index] == nil
        else { return }
        board.cells[index] = currentPlayer
        checkWin()
        if !gameOver {
            currentPlayer = currentPlayer.next
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
        // If no empty cells and no winner, it’s a draw
        if !board.cells.contains(where: { $0 == nil }) {
            winner = nil
            gameOver = true
        }
    }
}
