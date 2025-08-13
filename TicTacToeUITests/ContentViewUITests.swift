import XCTest

final class ContentViewUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Basic UI Tests
    
    func testAppLaunch() throws {
        // Verify the app launches successfully
        XCTAssertTrue(app.exists)
    }
    
    func testTitleDisplay() throws {
        // Check if the title is displayed
        let title = app.staticTexts["Tic Tac Toe"]
        XCTAssertTrue(title.exists)
    }
    
    func testGameBoardExists() throws {
        // Verify the game board is present
        let gameBoard = app.otherElements.containing(.any, identifier: "gameBoard").firstMatch
        XCTAssertTrue(gameBoard.exists)
    }
    
    func testResetButtonExists() throws {
        // Check if reset button is present
        let resetButton = app.buttons["Reset Game"]
        XCTAssertTrue(resetButton.exists)
    }
    
    // MARK: - Game Board Interaction Tests
    
    func testCellTapping() throws {
        // Tap on the first cell (top-left)
        let firstCell = app.otherElements.element(boundBy: 0)
        firstCell.tap()
        
        // Verify that an X appears (since X goes first)
        let xSymbol = app.staticTexts["X"]
        XCTAssertTrue(xSymbol.exists)
    }
    
    func testMultipleMoves() throws {
        // Make several moves
        let cells = app.otherElements.matching(identifier: "gameCell").allElementsBoundByIndex
        
        // First move - X
        cells[0].tap()
        
        // Second move - O
        cells[1].tap()
        
        // Third move - X
        cells[2].tap()
        
        // Verify moves were made
        let xSymbols = app.staticTexts.matching(NSPredicate(format: "label == 'X'"))
        let oSymbols = app.staticTexts.matching(NSPredicate(format: "label == 'O'"))
        
        XCTAssertEqual(xSymbols.count, 2)
        XCTAssertEqual(oSymbols.count, 1)
    }
    
    func testInvalidMove() throws {
        // Make a move
        let firstCell = app.otherElements.element(boundBy: 0)
        firstCell.tap()
        
        // Try to tap the same cell again (should not work)
        firstCell.tap()
        
        // Should still only have one X
        let xSymbols = app.staticTexts.matching(NSPredicate(format: "label == 'X'"))
        XCTAssertEqual(xSymbols.count, 1)
    }
    
    // MARK: - Bot Mode Tests
    
    func testBotToggle() throws {
        // Find and toggle the bot switch
        let botToggle = app.switches["Bot Player"]
        XCTAssertTrue(botToggle.exists)
        
        // Enable bot mode
        botToggle.tap()
        XCTAssertTrue(botToggle.value as? String == "1")
    }
    
    func testBotDifficultySelection() throws {
        // Enable bot mode first
        let botToggle = app.switches["Bot Player"]
        botToggle.tap()
        
        // Check if difficulty picker appears
        let difficultyPicker = app.pickers["Difficulty"]
        XCTAssertTrue(difficultyPicker.exists)
        
        // Select different difficulties
        let easyButton = app.buttons["Easy"]
        let intermediateButton = app.buttons["Intermediate"]
        let advancedButton = app.buttons["Advanced"]
        
        XCTAssertTrue(easyButton.exists)
        XCTAssertTrue(intermediateButton.exists)
        XCTAssertTrue(advancedButton.exists)
    }
    
    func testBotPlayerSelection() throws {
        // Enable bot mode
        let botToggle = app.switches["Bot Player"]
        botToggle.tap()
        
        // Check bot player selection
        let botPlayerPicker = app.pickers["Bot Player"]
        XCTAssertTrue(botPlayerPicker.exists)
        
        let xButton = app.buttons["X"]
        let oButton = app.buttons["O"]
        
        XCTAssertTrue(xButton.exists)
        XCTAssertTrue(oButton.exists)
    }
    
    // MARK: - Game Flow Tests
    
    func testWinDetection() throws {
        // Create a winning scenario for X (top row)
        let cells = app.otherElements.matching(identifier: "gameCell").allElementsBoundByIndex
        
        // X moves
        cells[0].tap() // Top-left
        cells[1].tap() // Top-center (O's move)
        cells[2].tap() // Top-right (X's move)
        cells[3].tap() // Middle-left (O's move)
        cells[4].tap() // Center (X's move)
        cells[5].tap() // Middle-right (O's move)
        cells[6].tap() // Bottom-left (X's move)
        
        // Should show win alert
        let winAlert = app.alerts.firstMatch
        XCTAssertTrue(winAlert.exists)
        
        let winTitle = winAlert.staticTexts["🎉 X Wins! 🎉"]
        XCTAssertTrue(winTitle.exists)
    }
    
    func testDrawDetection() throws {
        // Create a draw scenario
        let moves = [0, 1, 2, 4, 3, 5, 6, 8, 7] // X, O, X, O, X, O, X, O, X
        let cells = app.otherElements.matching(identifier: "gameCell").allElementsBoundByIndex
        
        for move in moves {
            cells[move].tap()
        }
        
        // Should show draw alert
        let drawAlert = app.alerts.firstMatch
        XCTAssertTrue(drawAlert.exists)
        
        let drawTitle = drawAlert.staticTexts["🤝 It's a Draw! 🤝"]
        XCTAssertTrue(drawTitle.exists)
    }
    
    // MARK: - Reset Functionality Tests
    
    func testResetGame() throws {
        // Make some moves
        let firstCell = app.otherElements.element(boundBy: 0)
        firstCell.tap()
        
        // Verify X is placed
        let xSymbol = app.staticTexts["X"]
        XCTAssertTrue(xSymbol.exists)
        
        // Reset the game
        let resetButton = app.buttons["Reset Game"]
        resetButton.tap()
        
        // Verify X is no longer there
        XCTAssertFalse(xSymbol.exists)
    }
    
    func testResetAfterWin() throws {
        // Create a win scenario
        let cells = app.otherElements.matching(identifier: "gameCell").allElementsBoundByIndex
        cells[0].tap() // X
        cells[1].tap() // O
        cells[2].tap() // X
        cells[3].tap() // O
        cells[4].tap() // X
        cells[5].tap() // O
        cells[6].tap() // X wins
        
        // Dismiss win alert
        let playAgainButton = app.buttons["Play Again"]
        playAgainButton.tap()
        
        // Verify board is cleared
        let xSymbols = app.staticTexts.matching(NSPredicate(format: "label == 'X'"))
        let oSymbols = app.staticTexts.matching(NSPredicate(format: "label == 'O'"))
        
        XCTAssertEqual(xSymbols.count, 0)
        XCTAssertEqual(oSymbols.count, 0)
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() throws {
        // Check if important elements have accessibility labels
        let resetButton = app.buttons["Reset Game"]
        XCTAssertTrue(resetButton.exists)
        
        let botToggle = app.switches["Bot Player"]
        XCTAssertTrue(botToggle.exists)
    }
    
    // MARK: - Performance Tests
    
    func testGamePerformance() throws {
        // Measure performance of making multiple moves
        measure {
            let cells = app.otherElements.matching(identifier: "gameCell").allElementsBoundByIndex
            
            // Make 5 moves
            for i in 0..<5 {
                cells[i].tap()
            }
        }
    }
    
    // MARK: - Bot Interaction Tests
    
    func testBotMakesMove() throws {
        // Enable bot mode
        let botToggle = app.switches["Bot Player"]
        botToggle.tap()
        
        // Make a move as human
        let firstCell = app.otherElements.element(boundBy: 0)
        firstCell.tap()
        
        // Wait for bot to respond
        let expectation = XCTestExpectation(description: "Bot makes move")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Check that bot made a move
            let allSymbols = self.app.staticTexts.matching(NSPredicate(format: "label IN {'X', 'O'}"))
            XCTAssertGreaterThanOrEqual(allSymbols.count, 2)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testBotFirstMove() throws {
        // Enable bot mode and set bot to play as X
        let botToggle = app.switches["Bot Player"]
        botToggle.tap()
        
        let xButton = app.buttons["X"]
        xButton.tap()
        
        // Wait for bot to make first move
        let expectation = XCTestExpectation(description: "Bot makes first move")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Check that bot made a move
            let allSymbols = self.app.staticTexts.matching(NSPredicate(format: "label IN {'X', 'O'}"))
            XCTAssertGreaterThanOrEqual(allSymbols.count, 1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
