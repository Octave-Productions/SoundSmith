//
//  MainScreen.swift
//  SoundSmith
//
//  Created by Marcy on 1/21/25.
//

import SwiftUI

struct MainScreen: View {
    @State private var noteBlocks: [NoteBlock] = [
        NoteBlock(pitch: "C", duration: 1.0, position: CGPoint(x: 28, y: 510), initialPosition: CGPoint(x: 28, y: 510)),
        NoteBlock(pitch: "C#", duration: 1.0, position: CGPoint(x: 57, y: 567), initialPosition: CGPoint(x: 57, y: 567)),
        NoteBlock(pitch: "D", duration: 1.0, position: CGPoint(x: 85, y: 510), initialPosition: CGPoint(x: 85, y: 510)),
        NoteBlock(pitch: "D#", duration: 1.0, position: CGPoint(x: 114, y: 567), initialPosition: CGPoint(x: 114, y: 567)),
        NoteBlock(pitch: "E", duration: 1.0, position: CGPoint(x: 142, y: 510), initialPosition: CGPoint(x: 142, y: 510)),
        NoteBlock(pitch: "F", duration: 1.0, position: CGPoint(x: 199, y: 510), initialPosition: CGPoint(x: 199, y: 510)),
        NoteBlock(pitch: "F#", duration: 1.0, position: CGPoint(x: 228, y: 567), initialPosition: CGPoint(x: 228, y: 567)),
        NoteBlock(pitch: "G", duration: 1.0, position: CGPoint(x: 256, y: 510), initialPosition: CGPoint(x: 256, y: 510)),
        NoteBlock(pitch: "G#", duration: 1.0, position: CGPoint(x: 285, y: 567), initialPosition: CGPoint(x: 285, y: 567)),
        NoteBlock(pitch: "A", duration: 1.0, position: CGPoint(x: 313, y: 510), initialPosition: CGPoint(x: 313, y: 510)),
        NoteBlock(pitch: "A#", duration: 1.0, position: CGPoint(x: 342, y: 567), initialPosition: CGPoint(x: 342, y: 567)),
        NoteBlock(pitch: "B", duration: 1.0, position: CGPoint(x: 370, y: 510), initialPosition: CGPoint(x: 370, y: 510))
    ]
    @State private var isPlaying = false
    @State private var linePosition: CGFloat = 0.0
    @State private var timer: Timer?

    private let rows = 4
    private let gridHeight: CGFloat = 400
    private let playSpeed: CGFloat = 100.0 // Points per second

    var body: some View {
        VStack {
            Text("Music Composer")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            GeometryReader { geometry in
                ZStack {
                    // Grid Background
                    ForEach(0..<rows, id: \.self) { row in
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: geometry.size.width, height: gridHeight / CGFloat(rows))
                            .position(
                                x: geometry.size.width / 2,
                                y: (gridHeight / CGFloat(rows)) * CGFloat(row) + (gridHeight / CGFloat(rows)) / 2
                            )
                    }

                    // Horizontal Grid Lines
                    ForEach(1..<rows, id: \.self) { row in
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: geometry.size.width, height: 1)
                            .position(
                                x: geometry.size.width / 2,
                                y: (gridHeight / CGFloat(rows)) * CGFloat(row)
                            )
                    }

                    // Playback Line
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 2, height: geometry.size.height)
                        .position(x: linePosition, y: geometry.size.height / 2)

                    // Note Blocks
                    ForEach(noteBlocks.indices, id: \.self) { index in
                        NoteBlockView(note: $noteBlocks[index], resetNoteBlock: resetNoteBlock, removeNoteBlock: removeNoteBlock)
                            .position(noteBlocks[index].position)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        let clampedY = min(max(gesture.location.y, 0), gridHeight)
                                        noteBlocks[index].position = CGPoint(x: gesture.location.x, y: clampedY)
                                    }
                                    .onEnded { _ in
                                        noteBlocks[index].position.y = snapToRow(noteBlocks[index].position.y, in: geometry.size.height)
                                        addNewNoteBlock(from: noteBlocks[index])
                                    }
                            )
                    }
                }
            }
            .frame(width: 400, height: gridHeight)

            // Control Buttons
            HStack(spacing: 20) {
                Button(action: togglePlay) {
                    Text(isPlaying ? "Stop" : "Play")
                        .frame(width: 100, height: 50)
                        .background(isPlaying ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: resetGrid) {
                    Text("Clear")
                        .frame(width: 100, height: 50)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .padding()
    }

    // Snaps the note block to the nearest row
    private func snapToRow(_ y: CGFloat, in height: CGFloat) -> CGFloat {
        let rowHeight = height / CGFloat(rows)
        let rowIndex = Int((y + rowHeight / 2) / rowHeight)
        let snappedY = CGFloat(rowIndex) * rowHeight + rowHeight / 2
        return min(max(snappedY, rowHeight / 2), height - rowHeight / 2)
    }

    private func resetIsPlayed() {
        noteBlocks.indices.forEach { index in
            noteBlocks[index].isPlayed = false
        }
    }

    private func togglePlay() {
        isPlaying.toggle()
        
        if isPlaying {
            resetIsPlayed()
            startPlayback()
        } else {
            stopPlayback()
        }
    }

    private func startPlayback() {
        linePosition = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            moveLine()
        }
    }

    private func stopPlayback() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
    }

    private func moveLine() {
        linePosition += playSpeed * 0.01
        
        if linePosition > UIScreen.main.bounds.width {
            stopPlayback()
        }
        
        playNotesAtLinePosition()
    }

    private func playNotesAtLinePosition() {
        let rowHeight = gridHeight / CGFloat(rows)

        let blocksToPlay = noteBlocks.filter {
            abs(linePosition - $0.position.x) < 10 && isNoteOnGridRow($0.position.y, rowHeight: rowHeight)
        }

        blocksToPlay.forEach { note in
            if let index = noteBlocks.firstIndex(where: { $0.id == note.id }) {
                if !noteBlocks[index].isPlayed {
                    SoundManager.shared.playSound(for: note.pitch)
                    noteBlocks[index].isPlayed = true
                }
            }
        }
    }

    private func isNoteOnGridRow(_ y: CGFloat, rowHeight: CGFloat) -> Bool {
        for row in 0..<rows {
            let rowCenter = CGFloat(row) * rowHeight + rowHeight / 2
            if abs(y - rowCenter) < rowHeight / 4 {
                return true
            }
        }
        return false
    }

    private func resetNoteBlock(note: NoteBlock) {
        if let index = noteBlocks.firstIndex(where: { $0.id == note.id }) {
            noteBlocks[index].position = noteBlocks[index].initialPosition
            noteBlocks[index].isPlayed = false
        }
    }

    private func addNewNoteBlock(from note: NoteBlock) {
        let newNoteBlock = NoteBlock(pitch: note.pitch, duration: note.duration, position: note.initialPosition, initialPosition: note.initialPosition)
        noteBlocks.append(newNoteBlock)
    }

    private func resetGrid() {
        noteBlocks.removeAll { note in
            return note.position != note.initialPosition
        }
    }
    
    private func removeNoteBlock(_ id: UUID) {
        // Find the note block by its ID
        if let index = noteBlocks.firstIndex(where: { $0.id == id }) {
            // Only remove the note block if its position is not the initial position
            if noteBlocks[index].position != noteBlocks[index].initialPosition {
                noteBlocks.remove(at: index)
            }
        }
    }
}

struct NoteBlockView: View {
    @Binding var note: NoteBlock
    var resetNoteBlock: (NoteBlock) -> Void
    var removeNoteBlock: (UUID) -> Void

    var body: some View {
        Text(note.pitch)
            .frame(width: 50, height: 50)
            .background(Color.yellow)
            .cornerRadius(8)
            .shadow(radius: 3)
            .onTapGesture {
                removeNoteBlock(note.id)
            }
    }
}

struct NoteBlock: Identifiable {
    var id = UUID()
    var pitch: String
    var duration: Double
    var position: CGPoint
    var initialPosition: CGPoint
    var isPlayed: Bool = false
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
