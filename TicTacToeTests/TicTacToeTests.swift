import XCTest
@testable import TicTacToe

final class TicTacToeTests: XCTestCase {
    /// X in the top row should be detected as a win.
    @MainActor func testWinCondition() {
        let gs = GameState()
        gs.board.cells = [.x, .x, .x,
                          nil, nil, nil,
                          nil, nil, nil]
        gs.checkWin()
        XCTAssertTrue(gs.gameOver)
        XCTAssertEqual(gs.winner, .x)
    }

    /// A full board with no three‐in‐a‐row is a draw.
    @MainActor func testDrawCondition() {
        let gs = GameState()
        gs.board.cells = [
          .x, .o, .x,
          .x, .o, .o,
          .o, .x, .x
        ]
        gs.checkWin()
        XCTAssertTrue(gs.gameOver)
        XCTAssertNil(gs.winner)
    }

    /// After one move, the currentPlayer should switch.
    @MainActor func testTurnSwitch() {
        let gs = GameState()
        gs.makeMove(at: 0)
        XCTAssertEqual(gs.board.cells[0], .x)
        XCTAssertEqual(gs.currentPlayer, .o)
    }
}
