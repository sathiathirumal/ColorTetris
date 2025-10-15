//
//  GameEngine.swift
//  ColorTetris
//

import SwiftUI
import Combine
import AVFoundation

class GameEngine: ObservableObject {
    // MARK: - Constants
    static let boardWidth = 10
    static let boardHeight = 20

    // MARK: - Published Properties
    @Published var board: [[Block?]] = Array(repeating: Array(repeating: nil, count: boardWidth), count: boardHeight)
    @Published var currentPiece: Tetromino?
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    @Published var flashingRows: Set<Int> = []

    // MARK: - Private Properties
    private var timer: Timer?
    private var dropInterval: TimeInterval = 1.0
    private var audioPlayer: AVAudioPlayer?

    // MARK: - Initialization

    init() {
        startNewGame()
    }

    // MARK: - Game Control

    func startNewGame() {
        board = Array(repeating: Array(repeating: nil, count: GameEngine.boardWidth), count: GameEngine.boardHeight)
        score = 0
        isGameOver = false
        flashingRows.removeAll()
        dropInterval = 1.0
        spawnNewPiece()
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: dropInterval, repeats: true) { [weak self] _ in
            self?.gameLoop()
        }
    }

    private func updateSpeed() {
        let oldInterval = dropInterval
        if score >= 1000 {
            dropInterval = 0.3
        } else if score >= 500 {
            dropInterval = 0.5
        } else if score >= 100 {
            dropInterval = 0.7
        }

        if oldInterval != dropInterval {
            startTimer()
        }
    }

    private func gameLoop() {
        guard !isGameOver else { return }
        moveDown()
    }

    private func spawnNewPiece() {
        let newPiece = Tetromino.random()

        // Check if the new piece can be placed
        if !canPlace(piece: newPiece) {
            isGameOver = true
            timer?.invalidate()
            return
        }

        currentPiece = newPiece
    }

    // MARK: - Movement

    func moveLeft() {
        guard var piece = currentPiece, !isGameOver else { return }
        piece.position.x -= 1
        if canPlace(piece: piece) {
            currentPiece = piece
        }
    }

    func moveRight() {
        guard var piece = currentPiece, !isGameOver else { return }
        piece.position.x += 1
        if canPlace(piece: piece) {
            currentPiece = piece
        }
    }

    func moveDown() {
        guard var piece = currentPiece, !isGameOver else { return }
        piece.position.y += 1

        if canPlace(piece: piece) {
            currentPiece = piece
        } else {
            // Lock the piece in place
            lockPiece()
            clearFullRows()
            spawnNewPiece()
        }
    }

    func rotate() {
        guard var piece = currentPiece, !isGameOver else { return }
        piece.rotation = (piece.rotation + 1) % 4
        if canPlace(piece: piece) {
            currentPiece = piece
        }
    }

    func hardDrop() {
        guard var piece = currentPiece, !isGameOver else { return }

        while canPlace(piece: piece) {
            piece.position.y += 1
        }

        piece.position.y -= 1
        currentPiece = piece

        lockPiece()
        clearFullRows()
        spawnNewPiece()
    }

    // MARK: - Collision Detection

    private func canPlace(piece: Tetromino) -> Bool {
        for blockPos in piece.blocks {
            // Check bounds
            if blockPos.x < 0 || blockPos.x >= GameEngine.boardWidth {
                return false
            }
            if blockPos.y < 0 {
                return false
            }
            if blockPos.y >= GameEngine.boardHeight {
                return false
            }

            // Check collision with existing blocks
            if board[blockPos.y][blockPos.x] != nil {
                return false
            }
        }
        return true
    }

    private func lockPiece() {
        guard let piece = currentPiece else { return }

        for blockPos in piece.blocks {
            if blockPos.y >= 0 && blockPos.y < GameEngine.boardHeight &&
               blockPos.x >= 0 && blockPos.x < GameEngine.boardWidth {
                board[blockPos.y][blockPos.x] = Block(color: piece.color)
            }
        }

        currentPiece = nil
    }

    // MARK: - Row Clearing

    private func clearFullRows() {
        var rowsCleared = 0
        var clearedRowIndices: [Int] = []

        for y in (0..<GameEngine.boardHeight).reversed() {
            if board[y].allSatisfy({ $0 != nil }) {
                clearedRowIndices.append(y)
                rowsCleared += 1
            }
        }

        if rowsCleared > 0 {
            // Start flashing animation
            flashingRows = Set(clearedRowIndices)
            
            // Play sound
            playBloinkSound()
            
            // Flash the rows 3 times before clearing
            flashRowsAndClear(rowIndices: clearedRowIndices, flashCount: 0)
        }
    }
    
    private func flashRowsAndClear(rowIndices: [Int], flashCount: Int) {
        let maxFlashes = 6 // 3 complete flash cycles (on/off)
        
        if flashCount < maxFlashes {
            // Toggle flash state - on even counts show flashing, on odd counts hide flashing
            if flashCount % 2 == 0 {
                flashingRows = Set(rowIndices)
            } else {
                flashingRows.removeAll()
            }
            
            // Continue flashing after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                self?.flashRowsAndClear(rowIndices: rowIndices, flashCount: flashCount + 1)
            }
        } else {
            // Clear the flashing state
            flashingRows.removeAll()
            
            // Remove cleared rows and add new empty rows at top
            for rowIndex in rowIndices.sorted() {
                board.remove(at: rowIndex)
                board.insert(Array(repeating: nil, count: GameEngine.boardWidth), at: 0)
            }

            // Update score: 10 points + height bonus for each row
            for rowIndex in rowIndices {
                let heightBonus = GameEngine.boardHeight - rowIndex
                score += 10 + heightBonus
            }

            updateSpeed()
        }
    }

    // MARK: - Sound

    private func playBloinkSound() {
        // Generate a simple "bloink" sound programmatically
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.generateBloinkSound()
        }
    }

    private func generateBloinkSound() {
        let sampleRate = 44100.0
        let duration = 0.15
        let frequency = 800.0

        let frameCount = Int(sampleRate * duration)
        var samples = [Float](repeating: 0.0, count: frameCount)

        for i in 0..<frameCount {
            let time = Double(i) / sampleRate
            let envelope = Float(exp(-time * 10.0)) // Decay envelope
            let wave = sin(2.0 * .pi * frequency * time)
            samples[i] = Float(wave) * envelope * 0.3
        }

        // Convert to audio buffer and play
        guard let audioBuffer = createAudioBuffer(samples: samples, sampleRate: sampleRate) else { return }

        DispatchQueue.main.async { [weak self] in
            self?.playAudioBuffer(audioBuffer)
        }
    }

    private func createAudioBuffer(samples: [Float], sampleRate: Double) -> AVAudioPCMBuffer? {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)) else {
            return nil
        }

        buffer.frameLength = buffer.frameCapacity
        if let channelData = buffer.floatChannelData?[0] {
            for i in 0..<samples.count {
                channelData[i] = samples[i]
            }
        }

        return buffer
    }

    private func playAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        let audioEngine = AVAudioEngine()
        let playerNode = AVAudioPlayerNode()

        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: buffer.format)

        do {
            try audioEngine.start()
            playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
            playerNode.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }

    // MARK: - Cleanup

    deinit {
        timer?.invalidate()
    }
}
