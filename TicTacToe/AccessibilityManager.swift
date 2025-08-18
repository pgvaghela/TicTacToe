import Foundation
import SwiftUI

/// Manages accessibility features and VoiceOver support
class AccessibilityManager: ObservableObject {
    @Published var isVoiceOverEnabled = false
    @Published var accessibilityLevel: AccessibilityLevel = .standard
    
    enum AccessibilityLevel: String, CaseIterable {
        case standard = "Standard"
        case enhanced = "Enhanced"
        case minimal = "Minimal"
        
        var description: String {
            switch self {
            case .standard:
                return "Standard accessibility with basic VoiceOver support"
            case .enhanced:
                return "Enhanced accessibility with detailed descriptions and hints"
            case .minimal:
                return "Minimal accessibility for experienced users"
            }
        }
    }
    
    init() {
        checkVoiceOverStatus()
    }
    
    /// Check if VoiceOver is currently enabled
    func checkVoiceOverStatus() {
        #if os(iOS)
        isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
        #else
        isVoiceOverEnabled = false
        #endif
    }
    
    /// Get accessibility label for a cell
    func cellAccessibilityLabel(for cell: Player?, at index: Int, currentPlayer: Player) -> String {
        let position = cellPositionDescription(for: index)
        
        if let player = cell {
            return "\(position) occupied by \(player.symbol)"
        } else {
            return "\(position) empty, tap to place \(currentPlayer.symbol)"
        }
    }
    
    /// Get accessibility hint for a cell
    func cellAccessibilityHint(for cell: Player?, isBotTurn: Bool) -> String? {
        if cell != nil {
            return "This cell is already occupied"
        } else if isBotTurn {
            return "Waiting for bot to make a move"
        } else {
            return "Double tap to place your mark"
        }
    }
    
    /// Get accessibility value for a cell
    func cellAccessibilityValue(for cell: Player?) -> String {
        return cell?.symbol ?? "Empty"
    }
    
    /// Get position description for cell index
    private func cellPositionDescription(for index: Int) -> String {
        let row = index / 3 + 1
        let col = index % 3 + 1
        return "Row \(row), Column \(col)"
    }
    
    /// Get accessibility label for current player indicator
    func currentPlayerAccessibilityLabel(currentPlayer: Player) -> String {
        return "Current player: \(currentPlayer.symbol)"
    }
    
    /// Get accessibility label for game status
    func gameStatusAccessibilityLabel(gameOver: Bool, winner: Player?) -> String {
        if gameOver {
            if let winner = winner {
                return "Game over. \(winner.symbol) wins!"
            } else {
                return "Game over. It's a draw!"
            }
        } else {
            return "Game in progress"
        }
    }
    
    /// Get accessibility label for bot controls
    func botControlsAccessibilityLabel(isEnabled: Bool, difficulty: BotDifficulty, botPlayer: Player) -> String {
        if isEnabled {
            return "Bot mode enabled. Difficulty: \(difficulty.rawValue). Bot plays as \(botPlayer.symbol)"
        } else {
            return "Bot mode disabled. Human vs Human game"
        }
    }
    
    /// Get accessibility hint for bot toggle
    func botToggleAccessibilityHint() -> String {
        return "Double tap to toggle bot player mode"
    }
    
    /// Get accessibility label for difficulty picker
    func difficultyAccessibilityLabel(difficulty: BotDifficulty) -> String {
        let descriptions = [
            BotDifficulty.easy: "Easy mode - bot makes random moves",
            BotDifficulty.intermediate: "Intermediate mode - bot blocks wins and takes opportunities",
            BotDifficulty.advanced: "Advanced mode - bot plays optimally using advanced algorithms"
        ]
        return descriptions[difficulty] ?? difficulty.rawValue
    }
    
    /// Get accessibility label for reset button
    func resetButtonAccessibilityLabel() -> String {
        return "Reset Game"
    }
    
    /// Get accessibility hint for reset button
    func resetButtonAccessibilityHint() -> String {
        return "Double tap to start a new game"
    }
    
    /// Get accessibility label for win announcement
    func winAnnouncementAccessibilityLabel(winner: Player) -> String {
        return "Congratulations! \(winner.symbol) has won the game!"
    }
    
    /// Get accessibility label for draw announcement
    func drawAnnouncementAccessibilityLabel() -> String {
        return "The game ended in a tie. Great match!"
    }
    
    /// Get accessibility traits for interactive elements
    func accessibilityTraits(for element: AccessibilityElement) -> UIAccessibilityTraits {
        switch element {
        case .cell:
            return .button
        case .toggle:
            return .button
        case .picker:
            return .adjustable
        case .button:
            return .button
        case .status:
            return .staticText
        }
    }
    
    /// Accessibility element types
    enum AccessibilityElement {
        case cell
        case toggle
        case picker
        case button
        case status
    }
    
    /// Get dynamic type size for accessibility
    func dynamicTypeSize(for level: AccessibilityLevel) -> DynamicTypeSize {
        switch level {
        case .minimal:
            return .large
        case .standard:
            return .xLarge
        case .enhanced:
            return .xxxLarge
        }
    }
    
    /// Get color scheme for accessibility
    func accessibilityColorScheme() -> ColorScheme? {
        // Return nil for automatic, or force light/dark for accessibility
        return nil
    }
    
    /// Check if reduced motion is enabled
    var isReducedMotionEnabled: Bool {
        #if os(iOS)
        return UIAccessibility.isReduceMotionEnabled
        #else
        return false
        #endif
    }
    
    /// Get animation duration based on accessibility settings
    func animationDuration(for baseDuration: Double) -> Double {
        if isReducedMotionEnabled {
            return baseDuration * 0.5
        }
        return baseDuration
    }
}
