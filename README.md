# 🎮 TicTacToe iOS App

A modern, polished TicTacToe game built with SwiftUI featuring an intelligent AI opponent with three difficulty levels.

## ✨ Features

### 🎯 Game Modes
- **Human vs Human**: Classic two-player gameplay
- **Human vs AI**: Play against an intelligent bot with three difficulty levels

### 🤖 AI Difficulty Levels
- **Easy**: Random moves - perfect for beginners
- **Intermediate**: Strategic play that blocks wins and takes opportunities
- **Advanced**: Uses minimax algorithm with alpha-beta pruning for optimal play

### 🎨 Modern UI/UX
- **Beautiful Design**: Modern gradient styling with smooth animations
- **Responsive Layout**: Optimized for all iOS devices
- **Haptic Feedback**: Tactile response for better user experience
- **Visual Feedback**: Press animations and smooth transitions

### 🎮 Game Features
- **Smart AI**: Bot automatically makes moves with natural timing
- **Player Selection**: Choose whether the bot plays as X or O
- **Win Detection**: Automatic win/draw detection with celebratory alerts
- **Game Reset**: Easy one-tap game reset functionality

## 🚀 Getting Started

### Prerequisites
- Xcode 14.0 or later
- iOS 16.0 or later
- macOS 13.0 or later (for development)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/pgvaghela/TicTacToe.git
   ```

2. Open the project in Xcode:
   ```bash
   cd TicTacToe
   open TicTacToe.xcodeproj
   ```

3. Build and run the project on your iOS device or simulator

## 🏗️ Architecture

### Core Components
- **GameModel.swift**: Game logic, AI algorithms, and state management
- **ContentView.swift**: Main UI with modern SwiftUI design
- **Player Enum**: Represents X and O players with turn management
- **Board Struct**: 3x3 game board with win detection logic

### AI Implementation
- **Easy Mode**: Random selection from available moves
- **Intermediate Mode**: Win-blocking and opportunity-taking strategy
- **Advanced Mode**: Minimax algorithm with alpha-beta pruning for perfect play

## 🎯 How to Play

1. **Enable Bot Mode**: Toggle "Bot Player" to play against AI
2. **Select Difficulty**: Choose Easy, Intermediate, or Advanced
3. **Choose Bot Player**: Set whether the bot plays as X or O
4. **Start Playing**: Tap any empty cell to make your move
5. **Watch the AI**: The bot will automatically respond after your move

## 🔧 Technical Details

### AI Algorithms
- **Minimax**: Recursive algorithm for optimal decision making
- **Alpha-Beta Pruning**: Optimization technique to reduce search space
- **Win Detection**: Efficient line-based win checking

### SwiftUI Features
- **@StateObject**: Reactive state management
- **@Published**: Automatic UI updates
- **Animations**: Spring-based smooth transitions
- **Gradients**: Modern visual styling

## 📱 Screenshots

*Screenshots will be added here*

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with SwiftUI and iOS development best practices
- AI algorithms inspired by classic game theory
- Modern UI design principles for optimal user experience

---

**Made with ❤️ using SwiftUI** 

