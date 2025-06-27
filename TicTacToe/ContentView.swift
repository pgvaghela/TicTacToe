import SwiftUI

struct ContentView: View {
    // Thinner strokes
    private let lineWidth: CGFloat = 6
    // Grid fills 80% of the smaller dimension
    private let gridScale: CGFloat = 0.8

    var body: some View {
        GeometryReader { proxy in
            // Compute a square size based on the view’s dimensions
            let rawSize = min(proxy.size.width, proxy.size.height)
            let size = rawSize * gridScale

            Path { path in
                for i in 1..<3 {
                    let offset = size / 3 * CGFloat(i)
                    // Vertical
                    path.move(to: CGPoint(x: offset, y: 0))
                    path.addLine(to: CGPoint(x: offset, y: size))
                    // Horizontal
                    path.move(to: CGPoint(x: 0, y: offset))
                    path.addLine(to: CGPoint(x: size, y: offset))
                }
            }
            .stroke(Color.primary, lineWidth: lineWidth)
            .frame(width: size, height: size)
            // Center the grid
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDisplayName("Light")
                .preferredColorScheme(.light)
            ContentView()
                .previewDisplayName("Dark")
                .preferredColorScheme(.dark)
        }
    }
}
