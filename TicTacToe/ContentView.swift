import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameState()
    private let lineWidth: CGFloat = 6
    private let gridScale: CGFloat = 0.8

    var body: some View {
        GeometryReader { proxy in
            let rawSize = min(proxy.size.width, proxy.size.height)
            let size = rawSize * gridScale
            let cellSize = size / 3

            ZStack {
                // Grid lines
                Path { path in
                    for i in 1..<3 {
                        let offset = cellSize * CGFloat(i)
                        path.move(to: CGPoint(x: offset, y: 0))
                        path.addLine(to: CGPoint(x: offset, y: size))
                        path.move(to: CGPoint(x: 0, y: offset))
                        path.addLine(to: CGPoint(x: size, y: offset))
                    }
                }
                .stroke(Color.primary, lineWidth: lineWidth)
                .frame(width: size, height: size)
                .position(x: proxy.size.width / 2,
                          y: proxy.size.height / 2 - 40)

                // Tappable cells
                VStack(spacing: 0) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<3) { col in
                                let idx = row * 3 + col
                                Button {
                                    game.makeMove(at: idx)
                                } label: {
                                    ZStack {
                                        Color.clear
                                        if let p = game.board.cells[idx] {
                                            Text(p.symbol)
                                                .font(.system(size: cellSize * 0.6, weight: .bold))
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                                .frame(width: cellSize, height: cellSize)
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
                        game.reset()
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
            // ❶ Alert for win/draw
            .alert(isPresented: $game.gameOver) {
                if let winner = game.winner {
                    return Alert(
                        title: Text("\(winner.symbol) Wins!"),
                        dismissButton: .default(Text("Play Again")) {
                            game.reset()
                        }
                    )
                } else {
                    return Alert(
                        title: Text("It's a Draw"),
                        dismissButton: .default(Text("Play Again")) {
                            game.reset()
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
