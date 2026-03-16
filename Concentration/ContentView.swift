//
//  ContentView.swift
//  Concentration
//
//  Created by Zimeng Yang on 3/15/26.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    @State private var totalGuesses = 0
    @State private var gameMessage = ""
    let tileBack = "⚪️"
    @State private var tiles: [String] = ["🚀", "🌶️", "🦅", "🐢", "🦋", "🌮", "🍕", "🦄"]
    @State private var emojiShowing: [Bool] = Array(repeating: false, count: 16)
    @State private var guesses: [Int] = []
    @State private var disableButtons = false
    @State private var audioPlayer: AVAudioPlayer!
    
    var body: some View {
        VStack {
            Text("Total Guesses: \(totalGuesses)")
                .font(.largeTitle)
                .fontWeight(.black)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]){
                ForEach(0..<16) { index in
                        Button(emojiShowing[index] == false ? tileBack : tiles[index]) {
                            buttonTapped(index: index)
                        }
                }
            }
            .font(.largeTitle)
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .controlSize(.large)
            .disabled(disableButtons)

            
            Text(gameMessage)
                .font(.largeTitle)
                .fontWeight(.black)
                .multilineTextAlignment(.center)
                .frame(height: 80)
                .minimumScaleFactor(0.5)
            
            
            Spacer()
            
            if guesses.count == 2 {
                if emojiShowing.contains(false) {
                    Button("Another Try?") {
                        disableButtons = false
                        if tiles[guesses[0]] != tiles[guesses[1]] {
                            emojiShowing[guesses[0]] = false
                            emojiShowing[guesses[1]] = false
                        }
                        guesses.removeAll()
                        gameMessage = ""
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.title)
                    .frame(height: 80)
                    .tint(tiles[guesses[0]] == tiles[guesses[1]] ? .mint : .red)
                } else {
                    Button("Play Again?") {
                        disableButtons = false
                        guesses.removeAll()
                        gameMessage = ""
                        emojiShowing = Array(repeating: false, count: 16)
                        totalGuesses = 0
                        tiles.shuffle()
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.title)
                    .frame(height: 80)
                    .tint(.orange)
                }
                
            } else {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 80)
            }
            
        }
        .padding()
        .onAppear {
            tiles = tiles + tiles
            tiles.shuffle()
            print(tiles)
        }
    }
    
    func buttonTapped(index: Int) {
        if !emojiShowing[index] {
            emojiShowing[index] = true
            totalGuesses += 1
            guesses.append(index)
            playSound(soundName: "tile-flip")
            print(guesses)
            print(emojiShowing)
            if guesses.count == 2 {
                disableButtons = true
                checkForMatch()
            }
        }
    }
    
    func checkForMatch() {
        if emojiShowing.contains(false) {
            if tiles[guesses[0]] == tiles[guesses[1]] {
                gameMessage = "✅ You Found a Match!"
                playSound(soundName: "correct")
            } else {
                gameMessage = "❌ Not a match. Try again."
                playSound(soundName: "wrong")
            }
        } else {
            gameMessage = "You've Guessed Them All!"
            playSound(soundName: "ta-da")
        }
    }
    
    func playSound(soundName: String) {
        if audioPlayer != nil && audioPlayer.isPlaying {
            audioPlayer.stop()
        }
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("😡 Could not read file named \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("😡 Error: \(error.localizedDescription) creawting audioPlayer")
        }
    }
}

#Preview {
    ContentView()
}
