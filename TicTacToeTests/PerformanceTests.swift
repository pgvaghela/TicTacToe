import XCTest
@testable import TicTacToe

final class PerformanceTests: XCTestCase {
    var gameState: GameState!
    
    override func setUp() {
        super.setUp()
        gameState = GameState()
    }
    
    override func tearDown() {
        gameState = nil
        super.tearDown()
    }
    
    // MARK: - Move Performance Tests
    
    func testMovePerformance() {
        measure {
            // Make multiple moves quickly
            for i in 0..<9 {
                gameState.makeMove(at: i)
            }
        }
    }
    
    func testWinDetectionPerformance() {
        // Setup a winning scenario
        gameState.makeMove(at: 0) // X
        gameState.makeMove(at: 3) // O
        gameState.makeMove(at: 1) // X
        gameState.makeMove(at: 4) // O
        
        measure {
            // This should trigger win detection
            gameState.makeMove(at: 2) // X wins
        }
    }
    
    func testDrawDetectionPerformance() {
        // Setup a draw scenario
        let moves = [0, 1, 2, 4, 3, 5, 6, 8]
        for move in moves {
            gameState.makeMove(at: move)
        }
        
        measure {
            // This should trigger draw detection
            gameState.makeMove(at: 7)
        }
    }
    
    // MARK: - AI Performance Tests
    
    func testEasyBotPerformance() {
        gameState.isBotEnabled = true
        gameState.botDifficulty = .easy
        gameState.botPlayer = .o
        
        measure {
            gameState.makeBotMove()
        }
    }
    
    func testIntermediateBotPerformance() {
        gameState.isBotEnabled = true
        gameState.botDifficulty = .intermediate
        gameState.botPlayer = .o
        
        measure {
            gameState.makeBotMove()
        }
    }
    
    func testAdvancedBotPerformance() {
        gameState.isBotEnabled = true
        gameState.botDifficulty = .advanced
        gameState.botPlayer = .o
        
        measure {
            gameState.makeBotMove()
        }
    }
    
    // MARK: - Board Operations Performance
    
    func testEmptyCellsCalculationPerformance() {
        var board = Board()
        // Add some moves
        board.cells[0] = .x
        board.cells[4] = .o
        board.cells[8] = .x
        
        measure {
            _ = board.emptyCells
        }
    }
    
    func testWinDetectionPerformance() {
        var board = Board()
        // Setup a winning board
        board.cells[0] = .x
        board.cells[1] = .x
        board.cells[2] = .x
        
        measure {
            _ = board.hasWinner(.x)
        }
    }
    
    func testWouldWinCalculationPerformance() {
        var board = Board()
        board.cells[0] = .x
        board.cells[1] = .x
        
        measure {
            _ = board.wouldWin(for: .x, at: 2)
        }
    }
    
    // MARK: - Game State Performance
    
    func testGameResetPerformance() {
        // Setup a game with some moves
        gameState.makeMove(at: 0)
        gameState.makeMove(at: 1)
        gameState.makeMove(at: 2)
        
        measure {
            gameState.reset()
        }
    }
    
    func testBotEnablePerformance() {
        measure {
            gameState.enableBot()
        }
    }
    
    // MARK: - Memory Performance Tests
    
    func testMemoryUsage() {
        var gameStates: [GameState] = []
        
        measure {
            for _ in 0..<100 {
                let newGame = GameState()
                gameStates.append(newGame)
            }
            gameStates.removeAll()
        }
    }
    
    // MARK: - Concurrent Operations Performance
    
    func testConcurrentMovePerformance() {
        let expectation = XCTestExpectation(description: "Concurrent moves")
        let queue = DispatchQueue(label: "test", attributes: .concurrent)
        
        measure {
            let group = DispatchGroup()
            
            for i in 0..<9 {
                group.enter()
                queue.async {
                    self.gameState.makeMove(at: i)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - UI Update Performance
    
    func testUIUpdatePerformance() {
        // Simulate rapid UI updates
        measure {
            for i in 0..<50 {
                gameState.makeMove(at: i % 9)
                gameState.reset()
            }
        }
    }
    
    // MARK: - Algorithm Performance Tests
    
    func testMinimaxPerformance() {
        gameState.isBotEnabled = true
        gameState.botDifficulty = .advanced
        gameState.botPlayer = .o
        
        // Setup a complex board state
        gameState.makeMove(at: 0) // X
        gameState.makeMove(at: 4) // O
        gameState.makeMove(at: 1) // X
        
        measure {
            gameState.makeBotMove()
        }
    }
    
    func testAlphaBetaPruningPerformance() {
        gameState.isBotEnabled = true
        gameState.botDifficulty = .advanced
        gameState.botPlayer = .o
        
        // Setup a scenario that benefits from alpha-beta pruning
        gameState.makeMove(at: 0) // X
        gameState.makeMove(at: 8) // O
        gameState.makeMove(at: 2) // X
        gameState.makeMove(at: 6) // O
        
        measure {
            gameState.makeBotMove()
        }
    }
    
    // MARK: - Edge Case Performance
    
    func testFullBoardPerformance() {
        // Fill the board almost completely
        let moves = [0, 1, 2, 3, 4, 5, 6, 7]
        for move in moves {
            gameState.makeMove(at: move)
        }
        
        measure {
            gameState.makeMove(at: 8) // Last move
        }
    }
    
    func testEmptyBoardPerformance() {
        measure {
            // Test operations on empty board
            _ = gameState.board.emptyCells
            _ = gameState.board.hasWinner(.x)
            _ = gameState.board.hasWinner(.o)
        }
    }
}
