//
//  GameModels.swift
//  ColorTetris
//

import SwiftUI

// MARK: - Basic Types

struct Position: Equatable {
    var x: Int
    var y: Int
}

// MARK: - Color Palette (16 colors across the spectrum)

enum BlockColor: CaseIterable {
    case red, orange, yellow, lime, green, mint, cyan, sky
    case blue, indigo, purple, magenta, pink, rose, coral, amber

    var color: Color {
        switch self {
        case .red: return Color(red: 1.0, green: 0.0, blue: 0.0)
        case .orange: return Color(red: 1.0, green: 0.5, blue: 0.0)
        case .yellow: return Color(red: 1.0, green: 1.0, blue: 0.0)
        case .lime: return Color(red: 0.5, green: 1.0, blue: 0.0)
        case .green: return Color(red: 0.0, green: 0.8, blue: 0.0)
        case .mint: return Color(red: 0.0, green: 1.0, blue: 0.5)
        case .cyan: return Color(red: 0.0, green: 1.0, blue: 1.0)
        case .sky: return Color(red: 0.0, green: 0.5, blue: 1.0)
        case .blue: return Color(red: 0.0, green: 0.0, blue: 1.0)
        case .indigo: return Color(red: 0.3, green: 0.0, blue: 0.5)
        case .purple: return Color(red: 0.5, green: 0.0, blue: 0.5)
        case .magenta: return Color(red: 1.0, green: 0.0, blue: 1.0)
        case .pink: return Color(red: 1.0, green: 0.4, blue: 0.7)
        case .rose: return Color(red: 1.0, green: 0.0, blue: 0.5)
        case .coral: return Color(red: 1.0, green: 0.3, blue: 0.3)
        case .amber: return Color(red: 1.0, green: 0.75, blue: 0.0)
        }
    }

    static func random() -> BlockColor {
        BlockColor.allCases.randomElement()!
    }
}

// MARK: - Block

struct Block: Equatable {
    let color: BlockColor
}

// MARK: - Tetromino Shapes

enum TetrominoShape: CaseIterable {
    case I, O, T, S, Z, J, L

    // Returns relative positions for each rotation state (0, 90, 180, 270 degrees)
    func positions(rotation: Int) -> [Position] {
        let rot = rotation % 4
        switch self {
        case .I:
            switch rot {
            case 0: return [Position(x: 0, y: 0), Position(x: 1, y: 0), Position(x: 2, y: 0), Position(x: 3, y: 0)]
            case 1: return [Position(x: 2, y: -1), Position(x: 2, y: 0), Position(x: 2, y: 1), Position(x: 2, y: 2)]
            case 2: return [Position(x: 0, y: 1), Position(x: 1, y: 1), Position(x: 2, y: 1), Position(x: 3, y: 1)]
            default: return [Position(x: 1, y: -1), Position(x: 1, y: 0), Position(x: 1, y: 1), Position(x: 1, y: 2)]
            }
        case .O:
            return [Position(x: 0, y: 0), Position(x: 1, y: 0), Position(x: 0, y: 1), Position(x: 1, y: 1)]
        case .T:
            switch rot {
            case 0: return [Position(x: 1, y: 0), Position(x: 0, y: 1), Position(x: 1, y: 1), Position(x: 2, y: 1)]
            case 1: return [Position(x: 1, y: 0), Position(x: 1, y: 1), Position(x: 2, y: 1), Position(x: 1, y: 2)]
            case 2: return [Position(x: 0, y: 1), Position(x: 1, y: 1), Position(x: 2, y: 1), Position(x: 1, y: 2)]
            default: return [Position(x: 1, y: 0), Position(x: 0, y: 1), Position(x: 1, y: 1), Position(x: 1, y: 2)]
            }
        case .S:
            switch rot {
            case 0: return [Position(x: 1, y: 0), Position(x: 2, y: 0), Position(x: 0, y: 1), Position(x: 1, y: 1)]
            case 1: return [Position(x: 1, y: 0), Position(x: 1, y: 1), Position(x: 2, y: 1), Position(x: 2, y: 2)]
            case 2: return [Position(x: 1, y: 1), Position(x: 2, y: 1), Position(x: 0, y: 2), Position(x: 1, y: 2)]
            default: return [Position(x: 0, y: 0), Position(x: 0, y: 1), Position(x: 1, y: 1), Position(x: 1, y: 2)]
            }
        case .Z:
            switch rot {
            case 0: return [Position(x: 0, y: 0), Position(x: 1, y: 0), Position(x: 1, y: 1), Position(x: 2, y: 1)]
            case 1: return [Position(x: 2, y: 0), Position(x: 1, y: 1), Position(x: 2, y: 1), Position(x: 1, y: 2)]
            case 2: return [Position(x: 0, y: 1), Position(x: 1, y: 1), Position(x: 1, y: 2), Position(x: 2, y: 2)]
            default: return [Position(x: 1, y: 0), Position(x: 0, y: 1), Position(x: 1, y: 1), Position(x: 0, y: 2)]
            }
        case .J:
            switch rot {
            case 0: return [Position(x: 0, y: 0), Position(x: 0, y: 1), Position(x: 1, y: 1), Position(x: 2, y: 1)]
            case 1: return [Position(x: 1, y: 0), Position(x: 2, y: 0), Position(x: 1, y: 1), Position(x: 1, y: 2)]
            case 2: return [Position(x: 0, y: 1), Position(x: 1, y: 1), Position(x: 2, y: 1), Position(x: 2, y: 2)]
            default: return [Position(x: 1, y: 0), Position(x: 1, y: 1), Position(x: 0, y: 2), Position(x: 1, y: 2)]
            }
        case .L:
            switch rot {
            case 0: return [Position(x: 2, y: 0), Position(x: 0, y: 1), Position(x: 1, y: 1), Position(x: 2, y: 1)]
            case 1: return [Position(x: 1, y: 0), Position(x: 1, y: 1), Position(x: 1, y: 2), Position(x: 2, y: 2)]
            case 2: return [Position(x: 0, y: 1), Position(x: 1, y: 1), Position(x: 2, y: 1), Position(x: 0, y: 2)]
            default: return [Position(x: 0, y: 0), Position(x: 1, y: 0), Position(x: 1, y: 1), Position(x: 1, y: 2)]
            }
        }
    }
}

// MARK: - Tetromino

struct Tetromino {
    let shape: TetrominoShape
    let color: BlockColor
    var position: Position
    var rotation: Int

    var blocks: [Position] {
        shape.positions(rotation: rotation).map { relPos in
            Position(x: position.x + relPos.x, y: position.y + relPos.y)
        }
    }

    static func random() -> Tetromino {
        Tetromino(
            shape: TetrominoShape.allCases.randomElement()!,
            color: BlockColor.random(),
            position: Position(x: 3, y: 0),
            rotation: 0
        )
    }
}
