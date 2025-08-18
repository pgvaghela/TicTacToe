import XCTest
@testable import TicTacToe

final class AccessibilityTests: XCTestCase {
    var accessibilityManager: AccessibilityManager!
    
    override func setUp() {
        super.setUp()
        accessibilityManager = AccessibilityManager()
    }
    
    override func tearDown() {
        accessibilityManager = nil
        super.tearDown()
    }
    
    // MARK: - Accessibility Manager Tests
    
    func testAccessibilityLevels() {
        XCTAssertEqual(AccessibilityManager.AccessibilityLevel.allCases.count, 3)
        XCTAssertTrue(AccessibilityManager.AccessibilityLevel.allCases.contains(.standard))
        XCTAssertTrue(AccessibilityManager.AccessibilityLevel.allCases.contains(.enhanced))
        XCTAssertTrue(AccessibilityManager.AccessibilityLevel.allCases.contains(.minimal))
    }
    
    func testAccessibilityLevelDescriptions() {
        let standard = AccessibilityManager.AccessibilityLevel.standard
        let enhanced = AccessibilityManager.AccessibilityLevel.enhanced
        let minimal = AccessibilityManager.AccessibilityLevel.minimal
        
        XCTAssertFalse(standard.description.isEmpty)
        XCTAssertFalse(enhanced.description.isEmpty)
        XCTAssertFalse(minimal.description.isEmpty)
        
        XCTAssertTrue(standard.description.contains("Standard"))
        XCTAssertTrue(enhanced.description.contains("Enhanced"))
        XCTAssertTrue(minimal.description.contains("Minimal"))
    }
    
    // MARK: - Cell Accessibility Tests
    
    func testCellAccessibilityLabelForEmptyCell() {
        let label = accessibilityManager.cellAccessibilityLabel(for: nil, at: 0, currentPlayer: .x)
        XCTAssertTrue(label.contains("Row 1, Column 1"))
        XCTAssertTrue(label.contains("empty"))
        XCTAssertTrue(label.contains("X"))
    }
    
    func testCellAccessibilityLabelForOccupiedCell() {
        let label = accessibilityManager.cellAccessibilityLabel(for: .o, at: 4, currentPlayer: .x)
        XCTAssertTrue(label.contains("Row 2, Column 2"))
        XCTAssertTrue(label.contains("occupied"))
        XCTAssertTrue(label.contains("O"))
    }
    
    func testCellAccessibilityHintForEmptyCell() {
        let hint = accessibilityManager.cellAccessibilityHint(for: nil, isBotTurn: false)
        XCTAssertEqual(hint, "Double tap to place your mark")
    }
    
    func testCellAccessibilityHintForOccupiedCell() {
        let hint = accessibilityManager.cellAccessibilityHint(for: .x, isBotTurn: false)
        XCTAssertEqual(hint, "This cell is already occupied")
    }
    
    func testCellAccessibilityHintForBotTurn() {
        let hint = accessibilityManager.cellAccessibilityHint(for: nil, isBotTurn: true)
        XCTAssertEqual(hint, "Waiting for bot to make a move")
    }
    
    func testCellAccessibilityValue() {
        XCTAssertEqual(accessibilityManager.cellAccessibilityValue(for: .x), "X")
        XCTAssertEqual(accessibilityManager.cellAccessibilityValue(for: .o), "O")
        XCTAssertEqual(accessibilityManager.cellAccessibilityValue(for: nil), "Empty")
    }
    
    // MARK: - Position Description Tests
    
    func testPositionDescriptions() {
        // Test all 9 positions
        let positions = [
            (0, "Row 1, Column 1"),
            (1, "Row 1, Column 2"),
            (2, "Row 1, Column 3"),
            (3, "Row 2, Column 1"),
            (4, "Row 2, Column 2"),
            (5, "Row 2, Column 3"),
            (6, "Row 3, Column 1"),
            (7, "Row 3, Column 2"),
            (8, "Row 3, Column 3")
        ]
        
        for (index, expected) in positions {
            let label = accessibilityManager.cellAccessibilityLabel(for: nil, at: index, currentPlayer: .x)
            XCTAssertTrue(label.contains(expected), "Position \(index) should contain \(expected)")
        }
    }
    
    // MARK: - Game Status Accessibility Tests
    
    func testCurrentPlayerAccessibilityLabel() {
        let xLabel = accessibilityManager.currentPlayerAccessibilityLabel(currentPlayer: .x)
        let oLabel = accessibilityManager.currentPlayerAccessibilityLabel(currentPlayer: .o)
        
        XCTAssertEqual(xLabel, "Current player: X")
        XCTAssertEqual(oLabel, "Current player: O")
    }
    
    func testGameStatusAccessibilityLabelForWin() {
        let label = accessibilityManager.gameStatusAccessibilityLabel(gameOver: true, winner: .x)
        XCTAssertTrue(label.contains("Game over"))
        XCTAssertTrue(label.contains("X wins"))
    }
    
    func testGameStatusAccessibilityLabelForDraw() {
        let label = accessibilityManager.gameStatusAccessibilityLabel(gameOver: true, winner: nil)
        XCTAssertTrue(label.contains("Game over"))
        XCTAssertTrue(label.contains("draw"))
    }
    
    func testGameStatusAccessibilityLabelForInProgress() {
        let label = accessibilityManager.gameStatusAccessibilityLabel(gameOver: false, winner: nil)
        XCTAssertTrue(label.contains("Game in progress"))
    }
    
    // MARK: - Bot Controls Accessibility Tests
    
    func testBotControlsAccessibilityLabelWhenEnabled() {
        let label = accessibilityManager.botControlsAccessibilityLabel(isEnabled: true, difficulty: .intermediate, botPlayer: .o)
        XCTAssertTrue(label.contains("Bot mode enabled"))
        XCTAssertTrue(label.contains("Intermediate"))
        XCTAssertTrue(label.contains("O"))
    }
    
    func testBotControlsAccessibilityLabelWhenDisabled() {
        let label = accessibilityManager.botControlsAccessibilityLabel(isEnabled: false, difficulty: .easy, botPlayer: .x)
        XCTAssertTrue(label.contains("Bot mode disabled"))
        XCTAssertTrue(label.contains("Human vs Human"))
    }
    
    func testBotToggleAccessibilityHint() {
        let hint = accessibilityManager.botToggleAccessibilityHint()
        XCTAssertTrue(hint.contains("Double tap"))
        XCTAssertTrue(hint.contains("toggle"))
    }
    
    func testDifficultyAccessibilityLabel() {
        let easyLabel = accessibilityManager.difficultyAccessibilityLabel(difficulty: .easy)
        let intermediateLabel = accessibilityManager.difficultyAccessibilityLabel(difficulty: .intermediate)
        let advancedLabel = accessibilityManager.difficultyAccessibilityLabel(difficulty: .advanced)
        
        XCTAssertTrue(easyLabel.contains("Easy mode"))
        XCTAssertTrue(easyLabel.contains("random"))
        
        XCTAssertTrue(intermediateLabel.contains("Intermediate mode"))
        XCTAssertTrue(intermediateLabel.contains("blocks wins"))
        
        XCTAssertTrue(advancedLabel.contains("Advanced mode"))
        XCTAssertTrue(advancedLabel.contains("optimally"))
    }
    
    // MARK: - Button Accessibility Tests
    
    func testResetButtonAccessibilityLabel() {
        let label = accessibilityManager.resetButtonAccessibilityLabel()
        XCTAssertEqual(label, "Reset Game")
    }
    
    func testResetButtonAccessibilityHint() {
        let hint = accessibilityManager.resetButtonAccessibilityHint()
        XCTAssertTrue(hint.contains("Double tap"))
        XCTAssertTrue(hint.contains("new game"))
    }
    
    func testWinAnnouncementAccessibilityLabel() {
        let xLabel = accessibilityManager.winAnnouncementAccessibilityLabel(winner: .x)
        let oLabel = accessibilityManager.winAnnouncementAccessibilityLabel(winner: .o)
        
        XCTAssertTrue(xLabel.contains("Congratulations"))
        XCTAssertTrue(xLabel.contains("X"))
        XCTAssertTrue(xLabel.contains("won"))
        
        XCTAssertTrue(oLabel.contains("Congratulations"))
        XCTAssertTrue(oLabel.contains("O"))
        XCTAssertTrue(oLabel.contains("won"))
    }
    
    func testDrawAnnouncementAccessibilityLabel() {
        let label = accessibilityManager.drawAnnouncementAccessibilityLabel()
        XCTAssertTrue(label.contains("tie"))
        XCTAssertTrue(label.contains("Great match"))
    }
    
    // MARK: - Accessibility Traits Tests
    
    func testAccessibilityTraits() {
        let cellTraits = accessibilityManager.accessibilityTraits(for: .cell)
        let toggleTraits = accessibilityManager.accessibilityTraits(for: .toggle)
        let pickerTraits = accessibilityManager.accessibilityTraits(for: .picker)
        let buttonTraits = accessibilityManager.accessibilityTraits(for: .button)
        let statusTraits = accessibilityManager.accessibilityTraits(for: .status)
        
        XCTAssertEqual(cellTraits, .button)
        XCTAssertEqual(toggleTraits, .button)
        XCTAssertEqual(pickerTraits, .adjustable)
        XCTAssertEqual(buttonTraits, .button)
        XCTAssertEqual(statusTraits, .staticText)
    }
    
    // MARK: - Dynamic Type Tests
    
    func testDynamicTypeSize() {
        let minimalSize = accessibilityManager.dynamicTypeSize(for: .minimal)
        let standardSize = accessibilityManager.dynamicTypeSize(for: .standard)
        let enhancedSize = accessibilityManager.dynamicTypeSize(for: .enhanced)
        
        XCTAssertEqual(minimalSize, .large)
        XCTAssertEqual(standardSize, .xLarge)
        XCTAssertEqual(enhancedSize, .xxxLarge)
    }
    
    // MARK: - Animation Tests
    
    func testAnimationDuration() {
        let baseDuration = 1.0
        
        // Test normal duration
        let normalDuration = accessibilityManager.animationDuration(for: baseDuration)
        XCTAssertEqual(normalDuration, baseDuration)
        
        // Note: We can't easily test reduced motion in unit tests
        // as it depends on system settings
    }
    
    // MARK: - VoiceOver Status Tests
    
    func testVoiceOverStatusCheck() {
        // This test verifies the method doesn't crash
        accessibilityManager.checkVoiceOverStatus()
        
        // The actual value depends on system settings, so we just verify it's a boolean
        XCTAssertTrue(accessibilityManager.isVoiceOverEnabled == true || accessibilityManager.isVoiceOverEnabled == false)
    }
    
    // MARK: - Reduced Motion Tests
    
    func testReducedMotionStatus() {
        // This test verifies the property is accessible
        let isReduced = accessibilityManager.isReducedMotionEnabled
        XCTAssertTrue(isReduced == true || isReduced == false)
    }
    
    // MARK: - Color Scheme Tests
    
    func testAccessibilityColorScheme() {
        let colorScheme = accessibilityManager.accessibilityColorScheme()
        // Should return nil for automatic
        XCTAssertNil(colorScheme)
    }
    
    // MARK: - Integration Tests
    
    func testAccessibilityManagerInitialization() {
        XCTAssertNotNil(accessibilityManager)
        XCTAssertEqual(accessibilityManager.accessibilityLevel, .standard)
        XCTAssertFalse(accessibilityManager.isVoiceOverEnabled) // Default should be false in tests
    }
    
    func testAccessibilityLevelChange() {
        accessibilityManager.accessibilityLevel = .enhanced
        XCTAssertEqual(accessibilityManager.accessibilityLevel, .enhanced)
        
        accessibilityManager.accessibilityLevel = .minimal
        XCTAssertEqual(accessibilityManager.accessibilityLevel, .minimal)
    }
}
