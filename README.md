# ColorTetris - iOS Tetris Game, vibe-coded with Claude Code!

A colorful Tetris game for iOS with unique features!

## Features Implemented ✅

- **16 Vibrant Colors**: Blocks appear in 16 different colors spread across the spectrum
- **Portrait Mode Only**: Optimized for vertical gameplay
- **Smart Scoring System**:
  - Base: 10 points per row cleared
  - Height Bonus: +1 point for each level above the bottom (higher rows = more points)
- **Progressive Difficulty**: Drop speed increases when you reach:
  - 100 points: Faster
  - 500 points: Even faster
  - 1000 points: Maximum speed
- **Sound Effects**: "Bloink" sound plays when rows are cleared
- **Game Over**: Game ends when a new piece can't be placed at the top

## How to Play

### Controls
- **Arrow Buttons**: Move piece left/right/down
- **Rotate Button**: Rotate the piece clockwise
- **Hard Drop**: Instantly drop piece to the bottom
- **New Game**: Reset and start over

### Game Rules
- Complete horizontal rows to clear them and score points
- Higher rows give more points (height bonus)
- Game speeds up as you score more points
- Game over when pieces stack to the top

## Project Structure

- `GameModels.swift` - Data structures (Tetromino, Block, Position, Colors)
- `GameEngine.swift` - Game logic, collision detection, scoring
- `GameView.swift` - SwiftUI interface and controls
- `ColorTetrisApp.swift` - App entry point with portrait lock

## Running the Game

1. Open `ColorTetris.xcodeproj` in Xcode
2. Select a simulator or device (iPhone)
3. Click the Play button (⌘R) to build and run
4. Enjoy!

## Next Steps for App Store

Before publishing:
1. **Test thoroughly** on different iPhone models
2. **Add app icon** in Assets.xcassets
3. **Create screenshots** for App Store listing
4. **Set up Apple Developer account** ($99/year)
5. **Configure signing & capabilities** in Xcode
6. **Prepare App Store metadata** (description, keywords, etc.)
7. **Submit for review** via App Store Connect

## Technical Details

- Built with SwiftUI
- Supports iOS 15+
- Portrait orientation only
- Programmatically generated sound effects
- 10x20 game board
- All 7 classic Tetromino shapes with rotation
