import SwiftUI
import UIKit    // for haptics

struct ContentView: View {
    @StateObject private var game = GameState()
    private let lineWidth: CGFloat = 4
    private let gridScale: CGFloat = 0.85

    var body: some View {
        GeometryReader { proxy in
            let rawSize = min(proxy.size.width, proxy.size.height)
            let size    = rawSize * gridScale
            let cell    = size / 3

            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor.systemBackground),
                        Color(UIColor.systemGray6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Title
                    Text("Tic Tac Toe")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.top, 20)
                    
                    // Game board container
                    ZStack {
                        // Board background with shadow
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
                            .frame(width: size + 20, height: size + 20)
                            .accessibilityIdentifier("gameBoard")
                        
                        // Grid lines with improved styling
                        Path { path in
                            for i in 1..<3 {
                                let off = cell * CGFloat(i)
                                path.move(to: CGPoint(x: off, y: 0))
                                path.addLine(to: CGPoint(x: off, y: size))
                                path.move(to: CGPoint(x: 0, y: off))
                                path.addLine(to: CGPoint(x: size, y: off))
                            }
                        }
                        .stroke(
                            LinearGradient(
                                colors: [.gray.opacity(0.3), .gray.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: lineWidth
                        )
                        .frame(width: size, height: size)
                        
                        // Cells with enhanced styling
                        VStack(spacing: 0) {
                            ForEach(0..<3) { row in
                                HStack(spacing: 0) {
                                    ForEach(0..<3) { col in
                                        let idx = row * 3 + col
                                        CellView(
                                            cell: game.board.cells[idx],
                                            currentPlayer: game.currentPlayer,
                                            isBotTurn: game.isBotEnabled && game.currentPlayer == game.botPlayer,
                                            onTap: {
                                                guard !game.gameOver else { return }
                                                // Don't allow moves if it's bot's turn
                                                if game.isBotEnabled && game.currentPlayer == game.botPlayer {
                                                    return
                                                }
                                                // haptic
                                                UIImpactFeedbackGenerator(style: .medium)
                                                    .impactOccurred()
                                                // animate the symbol appearing
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                                    game.makeMove(at: idx)
                                                }
                                            }
                                        )
                                        .frame(width: cell, height: cell)
                                        .accessibilityIdentifier("gameCell")
                                    }
                                }
                            }
                        }
                        .frame(width: size, height: size)
                    }
                    
                    // Game controls
                    VStack(spacing: 16) {
                        // Bot controls
                        VStack(spacing: 12) {
                            // Game mode toggle
                            HStack {
                                Text("Game Mode:")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Toggle("Bot Player", isOn: $game.isBotEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                    .onChange(of: game.isBotEnabled) { enabled in
                                        if enabled {
                                            game.enableBot()
                                        } else {
                                            game.reset()
                                        }
                                    }
                            }
                            .padding(.horizontal, 20)
                            
                            if game.isBotEnabled {
                                // Bot difficulty selection
                                VStack(spacing: 12) {
                                    Text("Bot Difficulty:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Picker("Difficulty", selection: $game.botDifficulty) {
                                        ForEach(BotDifficulty.allCases, id: \.self) { difficulty in
                                            Text(difficulty.rawValue).tag(difficulty)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .padding(.horizontal, 20)
                                    
                                    // Bot player selection
                                    HStack {
                                        Text("Bot plays as:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                                                            Picker("Bot Player", selection: $game.botPlayer) {
                                        Text("O").tag(Player.o)
                                        Text("X").tag(Player.x)
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .frame(width: 100)
                                    .onChange(of: game.botPlayer) { _ in
                                        if game.isBotEnabled {
                                            game.reset()
                                        }
                                    }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.systemGray6))
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal, 20)
                        
                        // Current player indicator
                        if !game.gameOver {
                            HStack {
                                Text("Current Player:")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(game.currentPlayer.symbol)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: game.currentPlayer == .x ? [.blue, .cyan] : [.red, .orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                            )
                        }
                        
                        // Reset button
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                game.reset()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(.headline)
                                Text("Reset Game")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .scaleEffect(game.gameOver ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: game.gameOver)
                        .padding(.bottom, 20)
                    }
                }
            }
            // Win/draw alert
            .alert(isPresented: $game.gameOver) {
                if let winner = game.winner {
                    return Alert(
                        title: Text("🎉 \(winner.symbol) Wins! 🎉"),
                        message: Text("Congratulations! \(winner.symbol) has won the game."),
                        dismissButton: .default(Text("Play Again")) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { 
                                game.reset() 
                            }
                        }
                    )
                } else {
                    return Alert(
                        title: Text("🤝 It's a Draw! 🤝"),
                        message: Text("The game ended in a tie. Great match!"),
                        dismissButton: .default(Text("Play Again")) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { 
                                game.reset() 
                            }
                        }
                    )
                }
            }
        }
    }
}

// Custom cell view for better styling
struct CellView: View {
    let cell: Player?
    let currentPlayer: Player
    let isBotTurn: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Cell background
                RoundedRectangle(cornerRadius: 12)
                    .fill(cellBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(cellBorderColor, lineWidth: 1)
                    )
                
                // Player symbol
                if let player = cell {
                    Text(player.symbol)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: player == .x ? [.blue, .cyan] : [.red, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var cellBackgroundColor: Color {
        if cell != nil {
            return Color(UIColor.systemGray6)
        } else if isBotTurn {
            return Color(UIColor.systemGray5)
        } else {
            return Color(UIColor.systemBackground)
        }
    }
    
    private var cellBorderColor: Color {
        if cell != nil {
            return Color.clear
        } else if isBotTurn {
            return Color.gray.opacity(0.3)
        } else {
            return Color.gray.opacity(0.2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().preferredColorScheme(.light)
            ContentView().preferredColorScheme(.dark)
        }
    }
}
