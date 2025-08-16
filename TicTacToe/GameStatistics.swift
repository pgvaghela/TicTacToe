import Foundation

/// Manages game statistics and player performance tracking
class GameStatistics: ObservableObject {
    @Published var totalGamesPlayed = 0
    @Published var gamesWonByX = 0
    @Published var gamesWonByO = 0
    @Published var gamesDrawn = 0
    @Published var currentWinStreak = 0
    @Published var longestWinStreak = 0
    @Published var averageGameDuration: TimeInterval = 0
    @Published var fastestWin: TimeInterval = Double.infinity
    @Published var botDifficultyStats: [BotDifficulty: BotStats] = [:]
    
    struct BotStats {
        var gamesPlayed = 0
        var gamesWon = 0
        var gamesLost = 0
        var gamesDrawn = 0
        var averageMoveTime: TimeInterval = 0
        var fastestMove: TimeInterval = Double.infinity
        var slowestMove: TimeInterval = 0
    }
    
    init() {
        // Initialize stats for each difficulty
        for difficulty in BotDifficulty.allCases {
            botDifficultyStats[difficulty] = BotStats()
        }
    }
    
    /// Record a game result
    func recordGameResult(winner: Player?, duration: TimeInterval, botDifficulty: BotDifficulty?) {
        totalGamesPlayed += 1
        
        if let winner = winner {
            if winner == .x {
                gamesWonByX += 1
                currentWinStreak += 1
            } else {
                gamesWonByO += 1
                currentWinStreak = 0
            }
            
            if currentWinStreak > longestWinStreak {
                longestWinStreak = currentWinStreak
            }
            
            if duration < fastestWin {
                fastestWin = duration
            }
        } else {
            gamesDrawn += 1
            currentWinStreak = 0
        }
        
        // Update average game duration
        let totalDuration = averageGameDuration * Double(totalGamesPlayed - 1) + duration
        averageGameDuration = totalDuration / Double(totalGamesPlayed)
        
        // Update bot statistics if applicable
        if let difficulty = botDifficulty {
            updateBotStats(difficulty: difficulty, winner: winner, duration: duration)
        }
    }
    
    /// Update bot statistics
    private func updateBotStats(difficulty: BotDifficulty, winner: Player?, duration: TimeInterval) {
        guard var stats = botDifficultyStats[difficulty] else { return }
        
        stats.gamesPlayed += 1
        
        if let winner = winner {
            if winner == .x {
                stats.gamesLost += 1
            } else {
                stats.gamesWon += 1
            }
        } else {
            stats.gamesDrawn += 1
        }
        
        // Update move time statistics (simplified - assuming average move time)
        let averageMoveTime = duration / 9.0 // Assuming average 9 moves per game
        stats.averageMoveTime = (stats.averageMoveTime * Double(stats.gamesPlayed - 1) + averageMoveTime) / Double(stats.gamesPlayed)
        
        if averageMoveTime < stats.fastestMove {
            stats.fastestMove = averageMoveTime
        }
        
        if averageMoveTime > stats.slowestMove {
            stats.slowestMove = averageMoveTime
        }
        
        botDifficultyStats[difficulty] = stats
    }
    
    /// Get win percentage for a player
    func winPercentage(for player: Player) -> Double {
        let totalWins = player == .x ? gamesWonByX : gamesWonByO
        return totalGamesPlayed > 0 ? Double(totalWins) / Double(totalGamesPlayed) * 100 : 0
    }
    
    /// Get draw percentage
    func drawPercentage() -> Double {
        return totalGamesPlayed > 0 ? Double(gamesDrawn) / Double(totalGamesPlayed) * 100 : 0
    }
    
    /// Get bot win percentage for a difficulty
    func botWinPercentage(for difficulty: BotDifficulty) -> Double {
        guard let stats = botDifficultyStats[difficulty], stats.gamesPlayed > 0 else { return 0 }
        return Double(stats.gamesWon) / Double(stats.gamesPlayed) * 100
    }
    
    /// Reset all statistics
    func resetStatistics() {
        totalGamesPlayed = 0
        gamesWonByX = 0
        gamesWonByO = 0
        gamesDrawn = 0
        currentWinStreak = 0
        longestWinStreak = 0
        averageGameDuration = 0
        fastestWin = Double.infinity
        
        for difficulty in BotDifficulty.allCases {
            botDifficultyStats[difficulty] = BotStats()
        }
    }
    
    /// Get formatted statistics string
    func getStatisticsSummary() -> String {
        return """
        Games Played: \(totalGamesPlayed)
        X Wins: \(gamesWonByX) (\(String(format: "%.1f", winPercentage(for: .x)))%)
        O Wins: \(gamesWonByO) (\(String(format: "%.1f", winPercentage(for: .o)))%)
        Draws: \(gamesDrawn) (\(String(format: "%.1f", drawPercentage()))%)
        Longest Win Streak: \(longestWinStreak)
        Average Game Duration: \(String(format: "%.1f", averageGameDuration))s
        Fastest Win: \(fastestWin == Double.infinity ? "N/A" : "\(String(format: "%.1f", fastestWin))s")
        """
    }
    
    /// Get bot statistics summary
    func getBotStatisticsSummary() -> String {
        var summary = "Bot Performance:\n"
        
        for difficulty in BotDifficulty.allCases {
            if let stats = botDifficultyStats[difficulty], stats.gamesPlayed > 0 {
                let winRate = botWinPercentage(for: difficulty)
                summary += "\(difficulty.rawValue): \(stats.gamesWon)/\(stats.gamesPlayed) (\(String(format: "%.1f", winRate))%)\n"
            }
        }
        
        return summary
    }
}
