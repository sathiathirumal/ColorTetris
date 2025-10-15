//
//  GameView.swift
//  ColorTetris
//

import SwiftUI

struct GameView: View {
    @StateObject private var game = GameEngine()
    @State private var dragOffset: CGFloat = 0
    @State private var hasTriggeredHardDrop: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    // Score Display
                    HStack {
                        Text("SCORE: \(game.score)")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: {
                            game.startNewGame()
                        }) {
                            Text("NEW GAME")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Game Board with Touch Controls
                    GameBoardView(game: game)
                        .frame(maxWidth: geometry.size.width * 0.9)
                        .gesture(
                            // Tap to rotate
                            TapGesture()
                                .onEnded { _ in
                                    game.rotate()
                                }
                        )
                        .simultaneousGesture(
                            // Drag to move left/right or hard drop down
                            DragGesture(minimumDistance: 10)
                                .onChanged { value in
                                    let blockSize = (geometry.size.width * 0.9) / CGFloat(GameEngine.boardWidth)
                                    let horizontalOffset = value.translation.width
                                    let verticalOffset = value.translation.height
                                    
                                    // Check if it's primarily a vertical swipe downward and we haven't triggered hard drop yet
                                    if !hasTriggeredHardDrop && abs(verticalOffset) > abs(horizontalOffset) && verticalOffset > 30 {
                                        // This is a downward swipe - trigger hard drop
                                        hasTriggeredHardDrop = true
                                        game.hardDrop()
                                        return
                                    }
                                    
                                    // Don't handle horizontal movement if we've already triggered hard drop
                                    if hasTriggeredHardDrop {
                                        return
                                    }
                                    
                                    // Otherwise handle horizontal movement
                                    let gridsMoved = Int((horizontalOffset - dragOffset) / blockSize)

                                    if gridsMoved > 0 {
                                        for _ in 0..<gridsMoved {
                                            game.moveRight()
                                        }
                                        dragOffset += CGFloat(gridsMoved) * blockSize
                                    } else if gridsMoved < 0 {
                                        for _ in 0..<abs(gridsMoved) {
                                            game.moveLeft()
                                        }
                                        dragOffset += CGFloat(gridsMoved) * blockSize
                                    }
                                }
                                .onEnded { value in
                                    let verticalOffset = value.translation.height
                                    let horizontalOffset = value.translation.width
                                    
                                    // Check if it was a quick downward swipe and we haven't triggered hard drop yet
                                    if !hasTriggeredHardDrop && abs(verticalOffset) > abs(horizontalOffset) && verticalOffset > 20 {
                                        game.hardDrop()
                                    }
                                    
                                    // Reset for next gesture
                                    dragOffset = 0
                                    hasTriggeredHardDrop = false
                                }
                        )

                    // Controls - Only Hard Drop button
                    VStack(spacing: 15) {
                        Text("Tap to rotate • Swipe left/right to move • Swipe down to drop")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)

                        // Hard Drop button
                        Button(action: {
                            game.hardDrop()
                        }) {
                            Text("HARD DROP")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 20)

                    Spacer()
                }

                // Game Over Overlay
                if game.isGameOver {
                    ZStack {
                        Color.black.opacity(0.8)
                            .ignoresSafeArea()

                        VStack(spacing: 20) {
                            Text("GAME OVER")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.red)

                            Text("Final Score: \(game.score)")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)

                            Button(action: {
                                game.startNewGame()
                            }) {
                                Text("PLAY AGAIN")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 15)
                                    .background(Color.green)
                                    .cornerRadius(15)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct GameBoardView: View {
    @ObservedObject var game: GameEngine

    var body: some View {
        GeometryReader { geometry in
            let blockSize = min(
                geometry.size.width / CGFloat(GameEngine.boardWidth),
                geometry.size.height / CGFloat(GameEngine.boardHeight)
            )

            VStack(spacing: 0) {
                ForEach(0..<GameEngine.boardHeight, id: \.self) { y in
                    HStack(spacing: 0) {
                        ForEach(0..<GameEngine.boardWidth, id: \.self) { x in
                            BlockView(
                                block: blockAt(x: x, y: y),
                                size: blockSize,
                                isFlashing: isFlashing(row: y),
                                xPosition: x,
                                yPosition: y
                            )
                        }
                    }
                }
            }
            .border(Color.gray, width: 2)
        }
        .aspectRatio(
            CGFloat(GameEngine.boardWidth) / CGFloat(GameEngine.boardHeight),
            contentMode: .fit
        )
    }

    private func blockAt(x: Int, y: Int) -> Block? {
        // Check if current piece occupies this position
        if let piece = game.currentPiece {
            for blockPos in piece.blocks {
                if blockPos.x == x && blockPos.y == y {
                    return Block(color: piece.color)
                }
            }
        }

        // Otherwise return the board block
        return game.board[y][x]
    }
    
    private func isFlashing(row: Int) -> Bool {
        return game.flashingRows.contains(row)
    }
}

struct BlockView: View {
    let block: Block?
    let size: CGFloat
    let isFlashing: Bool
    let xPosition: Int
    let yPosition: Int

    private var flashColor: Color {
        // Create checkerboard pattern: (x + y) % 2 determines the color
        let isEvenPosition = (xPosition + yPosition) % 2 == 0
        return isEvenPosition ? Color.black : Color.white
    }

    var body: some View {
        ZStack {
            if let block = block {
                Rectangle()
                    .fill(isFlashing ? flashColor : block.color.color)
                    .frame(width: size, height: size)
                    .border(Color.black.opacity(0.3), width: 1)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: size, height: size)
                    .border(Color.gray.opacity(0.2), width: 0.5)
            }
        }
    }
}

#Preview {
    GameView()
}
