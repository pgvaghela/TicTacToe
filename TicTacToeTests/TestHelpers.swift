import XCTest
@testable import TicTacToe

// MARK: - Test Helpers for Game Logic

extension XCTestCase {
    
    /// Creates a board with specific moves for testing
    func createBoard(with moves: [(Int, Player)]) -> Board {
        var board = Board()
        for (index, player) in moves {
            board.cells[index] = player
        }
        return board
    }
    
    /// Creates a winning board for the specified player
    func createWinningBoard(for player: Player, winType: WinType) -> Board {
        switch winType {
        case .horizontal(let row):
            let startIndex = row * 3
            return createBoard(with: [
                (startIndex, player),
                (startIndex + 1, player),
                (startIndex + 2, player)
            ])
        case .vertical(let col):
            return createBoard(with: [
                (col, player),
                (col + 3, player),
                (col + 6, player)
            ])
        case .diagonal(let isMain):
            if isMain {
                return createBoard(with: [(0, player), (4, player), (8, player)])
            } else {
                return createBoard(with: [(2, player), (4, player), (6, player)])
            }
        }
    }
    
    /// Creates a draw board
    func createDrawBoard() -> Board {
        return createBoard(with: [
            (0, .x), (1, .o), (2, .x),
            (3, .o), (4, .x), (5, .o),
            (6, .o), (7, .x), (8, .o)
        ])
    }
    
    /// Waits for an async operation with timeout
    func waitForAsyncOperation(timeout: TimeInterval = 1.0, operation: @escaping () -> Void) {
        let expectation = XCTestExpectation(description: "Async operation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            operation()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }
    
    /// Asserts that a board has the expected state
    func assertBoardState(_ board: Board, expectedMoves: [(Int, Player)]) {
        for (index, expectedPlayer) in expectedMoves {
            XCTAssertEqual(board.cells[index], expectedPlayer, "Cell at index \(index) should contain \(expectedPlayer.symbol)")
        }
    }
    
    /// Asserts that a game state has the expected properties
    func assertGameState(_ gameState: GameState, 
                        currentPlayer: Player? = nil,
                        gameOver: Bool? = nil,
                        winner: Player? = nil,
                        isBotEnabled: Bool? = nil) {
        if let expectedPlayer = currentPlayer {
            XCTAssertEqual(gameState.currentPlayer, expectedPlayer, "Current player should be \(expectedPlayer.symbol)")
        }
        if let expectedGameOver = gameOver {
            XCTAssertEqual(gameState.gameOver, expectedGameOver, "Game over should be \(expectedGameOver)")
        }
        if let expectedWinner = winner {
            XCTAssertEqual(gameState.winner, expectedWinner, "Winner should be \(expectedWinner.symbol)")
        }
        if let expectedBotEnabled = isBotEnabled {
            XCTAssertEqual(gameState.isBotEnabled, expectedBotEnabled, "Bot enabled should be \(expectedBotEnabled)")
        }
    }
}

// MARK: - Win Type Enum

enum WinType {
    case horizontal(Int) // row number (0-2)
    case vertical(Int)   // column number (0-2)
    case diagonal(Bool)  // true for main diagonal (0,4,8), false for other (2,4,6)
}

// MARK: - Test Data

struct TestData {
    static let allWinLines = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], // horizontal
        [0, 3, 6], [1, 4, 7], [2, 5, 8], // vertical
        [0, 4, 8], [2, 4, 6]             // diagonal
    ]
    
    static let cornerPositions = [0, 2, 6, 8]
    static let edgePositions = [1, 3, 5, 7]
    static let centerPosition = 4
    
    static let winningCombinations: [(String, [Int])] = [
        ("Top Row", [0, 1, 2]),
        ("Middle Row", [3, 4, 5]),
        ("Bottom Row", [6, 7, 8]),
        ("Left Column", [0, 3, 6]),
        ("Center Column", [1, 4, 7]),
        ("Right Column", [2, 5, 8]),
        ("Main Diagonal", [0, 4, 8]),
        ("Other Diagonal", [2, 4, 6])
    ]
}

// MARK: - Performance Test Helpers

extension XCTestCase {
    
    /// Measures the performance of making multiple moves
    func measureMovePerformance(moves: [Int], gameState: GameState) {
        measure {
            for move in moves {
                gameState.makeMove(at: move)
            }
        }
    }
    
    /// Measures the performance of AI move calculation
    func measureAIPerformance(gameState: GameState, difficulty: BotDifficulty) {
        gameState.botDifficulty = difficulty
        gameState.isBotEnabled = true
        
        measure {
            gameState.makeBotMove()
        }
    }
}

// MARK: - Mock Objects for Testing

class MockGameState: ObservableObject {
    @Published var board = Board()
    @Published var currentPlayer: Player = .x
    @Published var gameOver = false
    @Published var winner: Player? = nil
    @Published var isBotEnabled = false
    @Published var botDifficulty: BotDifficulty = .intermediate
    @Published var botPlayer: Player = .o
    
    var moveCount = 0
    var lastMove: Int?
    
    func makeMove(at index: Int) {
        guard !gameOver && index >= 0 && index < 9 && board.cells[index] == nil else { return }
        
        board.cells[index] = currentPlayer
        moveCount += 1
        lastMove = index
        
        // Simple win detection for testing
        checkWin()
        
        if !gameOver {
            currentPlayer = currentPlayer.next
        }
    }
    
    private func checkWin() {
        for line in TestData.allWinLines {
            if let p = board.cells[line[0]],
               board.cells[line[1]] == p,
               board.cells[line[2]] == p {
                winner = p
                gameOver = true
                return
            }
        }
        
        if !board.cells.contains(where: { $0 == nil }) {
            gameOver = true
        }
    }
    
    func reset() {
        board = Board()
        currentPlayer = .x
        gameOver = false
        winner = nil
        moveCount = 0
        lastMove = nil
    }
}
