import XCTest
@testable import TicTacToe

final class GameModelTests: XCTestCase {
    var gameState: GameState!
    
    override func setUp() {
        super.setUp()
        gameState = GameState()
    }
    
    override func tearDown() {
        gameState = nil
        super.tearDown()
    }
    
    // MARK: - Board Tests
    
    func testEmptyBoard() {
        let board = Board()
        XCTAssertEqual(board.cells.count, 9)
        XCTAssertTrue(board.cells.allSatisfy { $0 == nil })
        XCTAssertEqual(board.emptyCells.count, 9)
    }
    
    func testBoardWithMoves() {
        var board = Board()
        board.cells[0] = .x
        board.cells[4] = .o
        board.cells[8] = .x
        
        XCTAssertEqual(board.emptyCells.count, 6)
        XCTAssertTrue(board.emptyCells.contains(1))
        XCTAssertTrue(board.emptyCells.contains(2))
        XCTAssertTrue(board.emptyCells.contains(3))
        XCTAssertTrue(board.emptyCells.contains(5))
        XCTAssertTrue(board.emptyCells.contains(6))
        XCTAssertTrue(board.emptyCells.contains(7))
    }
    
    // MARK: - Win Detection Tests
    
    func testHorizontalWin() {
        var board = Board()
        // Top row win for X
        board.cells[0] = .x
        board.cells[1] = .x
        board.cells[2] = .x
        
        XCTAssertTrue(board.hasWinner(.x))
        XCTAssertFalse(board.hasWinner(.o))
    }
    
    func testVerticalWin() {
        var board = Board()
        // Left column win for O
        board.cells[0] = .o
        board.cells[3] = .o
        board.cells[6] = .o
        
        XCTAssertTrue(board.hasWinner(.o))
        XCTAssertFalse(board.hasWinner(.x))
    }
    
    func testDiagonalWin() {
        var board = Board()
        // Diagonal win for X
        board.cells[0] = .x
        board.cells[4] = .x
        board.cells[8] = .x
        
        XCTAssertTrue(board.hasWinner(.x))
        XCTAssertFalse(board.hasWinner(.o))
    }
    
    func testNoWin() {
        var board = Board()
        board.cells[0] = .x
        board.cells[1] = .o
        board.cells[2] = .x
        
        XCTAssertFalse(board.hasWinner(.x))
        XCTAssertFalse(board.hasWinner(.o))
    }
    
    // MARK: - Would Win Tests
    
    func testWouldWin() {
        var board = Board()
        // Setup: X has two in a row
        board.cells[0] = .x
        board.cells[1] = .x
        
        XCTAssertTrue(board.wouldWin(for: .x, at: 2))
        XCTAssertFalse(board.wouldWin(for: .o, at: 2))
    }
    
    func testWouldNotWin() {
        var board = Board()
        board.cells[0] = .x
        board.cells[1] = .o
        
        XCTAssertFalse(board.wouldWin(for: .x, at: 2))
        XCTAssertFalse(board.wouldWin(for: .o, at: 2))
    }
    
    // MARK: - Game State Tests
    
    func testInitialGameState() {
        XCTAssertEqual(gameState.currentPlayer, .x)
        XCTAssertFalse(gameState.gameOver)
        XCTAssertNil(gameState.winner)
        XCTAssertFalse(gameState.isBotEnabled)
        XCTAssertEqual(gameState.botDifficulty, .intermediate)
        XCTAssertEqual(gameState.botPlayer, .o)
    }
    
    func testMakeMove() {
        gameState.makeMove(at: 0)
        
        XCTAssertEqual(gameState.board.cells[0], .x)
        XCTAssertEqual(gameState.currentPlayer, .o)
        XCTAssertFalse(gameState.gameOver)
    }
    
    func testInvalidMove() {
        // Try to move on occupied cell
        gameState.makeMove(at: 0)
        gameState.makeMove(at: 0) // Should not work
        
        XCTAssertEqual(gameState.board.cells[0], .x)
        XCTAssertEqual(gameState.currentPlayer, .o)
    }
    
    func testWinDetection() {
        // X wins with top row
        gameState.makeMove(at: 0) // X
        gameState.makeMove(at: 3) // O
        gameState.makeMove(at: 1) // X
        gameState.makeMove(at: 4) // O
        gameState.makeMove(at: 2) // X wins
        
        XCTAssertTrue(gameState.gameOver)
        XCTAssertEqual(gameState.winner, .x)
    }
    
    func testDrawDetection() {
        // Create a draw scenario
        let moves = [0, 1, 2, 4, 3, 5, 6, 8, 7] // X, O, X, O, X, O, X, O, X
        for move in moves {
            gameState.makeMove(at: move)
        }
        
        XCTAssertTrue(gameState.gameOver)
        XCTAssertNil(gameState.winner)
    }
    
    // MARK: - Bot Tests
    
    func testBotEasyMode() {
        gameState.isBotEnabled = true
        gameState.botDifficulty = .easy
        gameState.botPlayer = .o
        gameState.currentPlayer = .x
        
        // Make a move as X
        gameState.makeMove(at: 0)
        
        // Bot should make a move after delay
        let expectation = XCTestExpectation(description: "Bot makes move")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Check that bot made a move
            let occupiedCells = self.gameState.board.cells.filter { $0 != nil }
            XCTAssertEqual(occupiedCells.count, 2)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testBotIntermediateMode() {
        gameState.isBotEnabled = true
        gameState.botDifficulty = .intermediate
        gameState.botPlayer = .o
        gameState.currentPlayer = .x
        
        // Setup: X has two in a row, bot should block
        gameState.makeMove(at: 0) // X
        gameState.makeMove(at: 4) // O (center)
        gameState.makeMove(at: 1) // X (now X has 0,1 - should win at 2)
        
        // Bot should block the win
        let expectation = XCTestExpectation(description: "Bot blocks win")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertEqual(self.gameState.board.cells[2], .o)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testBotAdvancedMode() {
        gameState.isBotEnabled = true
        gameState.botDifficulty = .advanced
        gameState.botPlayer = .o
        gameState.currentPlayer = .x
        
        // Bot should play optimally
        gameState.makeMove(at: 0) // X
        
        let expectation = XCTestExpectation(description: "Bot makes optimal move")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Advanced bot should take center if available
            XCTAssertEqual(self.gameState.board.cells[4], .o)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Player Tests
    
    func testPlayerNext() {
        XCTAssertEqual(Player.x.next, .o)
        XCTAssertEqual(Player.o.next, .x)
    }
    
    func testPlayerSymbol() {
        XCTAssertEqual(Player.x.symbol, "X")
        XCTAssertEqual(Player.o.symbol, "O")
    }
    
    func testPlayerEquality() {
        XCTAssertEqual(Player.x, .x)
        XCTAssertEqual(Player.o, .o)
        XCTAssertNotEqual(Player.x, .o)
    }
    
    // MARK: - Bot Difficulty Tests
    
    func testBotDifficultyCases() {
        XCTAssertEqual(BotDifficulty.allCases.count, 3)
        XCTAssertTrue(BotDifficulty.allCases.contains(.easy))
        XCTAssertTrue(BotDifficulty.allCases.contains(.intermediate))
        XCTAssertTrue(BotDifficulty.allCases.contains(.advanced))
    }
    
    func testBotDifficultyRawValues() {
        XCTAssertEqual(BotDifficulty.easy.rawValue, "Easy")
        XCTAssertEqual(BotDifficulty.intermediate.rawValue, "Intermediate")
        XCTAssertEqual(BotDifficulty.advanced.rawValue, "Advanced")
    }
    
    // MARK: - Game Reset Tests
    
    func testGameReset() {
        // Make some moves
        gameState.makeMove(at: 0)
        gameState.makeMove(at: 1)
        
        // Reset
        gameState.reset()
        
        XCTAssertEqual(gameState.currentPlayer, .x)
        XCTAssertFalse(gameState.gameOver)
        XCTAssertNil(gameState.winner)
        XCTAssertTrue(gameState.board.cells.allSatisfy { $0 == nil })
    }
    
    func testBotResetWithX() {
        gameState.isBotEnabled = true
        gameState.botPlayer = .x
        gameState.reset()
        
        // Bot should make first move after reset
        let expectation = XCTestExpectation(description: "Bot makes first move")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let occupiedCells = self.gameState.board.cells.filter { $0 != nil }
            XCTAssertEqual(occupiedCells.count, 1)
            XCTAssertEqual(self.gameState.currentPlayer, .o)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
