import SwiftUI
import UIKit    // for haptics

struct ContentView: View {
    @StateObject private var game = GameState()
    private let lineWidth: CGFloat = 6
    private let gridScale: CGFloat = 0.8

    var body: some View {
        GeometryReader { proxy in
            let rawSize = min(proxy.size.width, proxy.size.height)
            let size    = rawSize * gridScale
            let cell    = size / 3

            ZStack {
                // Grid lines
                Path { path in
                    for i in 1..<3 {
                        let off = cell * CGFloat(i)
                        path.move(to: CGPoint(x: off, y: 0))
                        path.addLine(to: CGPoint(x: off, y: size))
                        path.move(to: CGPoint(x: 0, y: off))
                        path.addLine(to: CGPoint(x: size, y: off))
                    }
                }
                .stroke(Color.primary, lineWidth: lineWidth)
                .frame(width: size, height: size)
                .position(x: proxy.size.width / 2,
                          y: proxy.size.height / 2 - 40)

                // Cells with X/O and animations
                VStack(spacing: 0) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<3) { col in
                                let idx = row * 3 + col
                                ZStack {
                                    // subtle background
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(UIColor.systemGray6))
                                        .frame(width: cell, height: cell)

                                    if let p = game.board.cells[idx] {
                                        Text(p.symbol)
                                            .font(.system(size: cell * 0.6, weight: .bold))
                                            .foregroundColor(.primary)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard !game.gameOver else { return }
                                    // haptic
                                    UIImpactFeedbackGenerator(style: .medium)
                                        .impactOccurred()
                                    // animate the symbol appearing
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                        game.makeMove(at: idx)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(width: size, height: size)
                .position(x: proxy.size.width / 2,
                          y: proxy.size.height / 2 - 40)

                // Reset button
                VStack {
                    Spacer()
                    Button("Reset") {
                        withAnimation {
                            game.reset()
                        }
                    }
                    .font(.headline)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.bottom, 40)
                }
            }
            // Win/draw alert from yesterday stays in place
            .alert(isPresented: $game.gameOver) {
                if let winner = game.winner {
                    return Alert(
                        title: Text("\(winner.symbol) Wins!"),
                        dismissButton: .default(Text("Play Again")) {
                            withAnimation { game.reset() }
                        }
                    )
                } else {
                    return Alert(
                        title: Text("It's a Draw"),
                        dismissButton: .default(Text("Play Again")) {
                            withAnimation { game.reset() }
                        }
                    )
                }
            }
        }
        .background(Color(UIColor.systemBackground))
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
