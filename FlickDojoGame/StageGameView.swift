//
//  StageGameView.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/12.
//

import SwiftUI

struct StageGameView: View {
    
    let stage: Stage
    let onFinish: (Int, Int) -> Void

    @State private var currentWordIndex = 0
    @State private var currentCharIndex = 0
    @State private var totalCharNum = 0
    @State private var timeRemaining = 20.0
    
    @State private var userInput = ""
    @State private var wrongInput = ""
    
    @State private var isFinished = false
    @State private var isAllClear = false
    @State private var timerStarted = false
    @State private var isPaused = false

    @FocusState private var isInputFocused: Bool
    
    @State private var timer: Timer? = nil

    init(stage: Stage, onFinish: @escaping (Int, Int) -> Void) {
        self.stage = stage
        self.onFinish = onFinish
    }
    
    var wordList: [WordItem] {
        stage.words
    }


    var body: some View {
        ZStack {
            Image(.gameback)
                .resizable()
                .ignoresSafeArea()
                .opacity(0.8)
            
            VStack{
                HStack{
                    
                    Spacer()
                    // 終了ボタン
                    if !isFinished{
                        Button(action: {
                            playSE(fileName: "1tap")
                            isPaused = true
                            timer?.invalidate()
                            isInputFocused = false
                        }) {
                            Text("中断")
                                .font(.headline)
                                .bold()
                                .frame(width: 60, height: 25)
                                .padding(10)
                                .background(Color.red.opacity(0.9))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.trailing,75)
                    }
                }
                Spacer()
            }

            VStack(spacing: 20) {
                Spacer().frame(height: 50)

                if !isFinished {
                    if !timerStarted {
                        Text("文字を入力したらスタート！")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .frame(height: 1)
                    }

                    // 少数表示
                    Text(String(format: "残り時間: %.1f 秒", timeRemaining))
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }

                if isFinished {
                    
                    if isAllClear {
                        Image(.endGameOk)
                            .resizable()
                    } else {
                        Image(.endGameNg)
                            .resizable()
                    }
                    
                    Spacer().frame(height: 50)
                    
                } else {
                    ZStack{
                        Image(.makimono)
                            .resizable()
                            .frame(width: 460, height: 190)
                            .ignoresSafeArea()
                        // 問題の出力
                        FuriganaText(
                            kanji: wordList[currentWordIndex].kanji,
                            reading: wordList[currentWordIndex].reading,
                            correctCount: currentCharIndex
                        )
                    }
                    
                    // 入力された文字の出力
                    HStack(spacing: 4) {

                        if !wrongInput.isEmpty {
                            Text(wrongInput)
                                .foregroundColor(.red)
                                .font(.largeTitle)
                        } else {
                            Text(" ")
                                .font(.largeTitle)
                            
                        }
                    }

                    TextField("", text: $userInput)
                        .focused($isInputFocused)
                        .onSubmit { isInputFocused = true }
                        .onChange(of: userInput) { checkInput() }
                        .opacity(0.01)
                        .frame(width: 1, height: 1)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                isInputFocused = true
                            }
                        }
                    
                    
                }
            }
            .padding()
            
            // 中断オーバーレイ（薄暗い背景＋中央ボタン）
            if isPaused {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                VStack{
                    
                    Spacer().frame(height: 160)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            playSE(fileName: "Ticket")
                            isInputFocused = true
                            isPaused = false
                            startTimer()
                            
                        }) {
                            Text("再開")
                                .font(.title)
                                .padding()
                                .frame(width: 150)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            isPaused = false
                            endGame()
                        }) {
                            Text("終了")
                            .font(.title)
                            .padding()
                            .frame(width: 150)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    Spacer()
                }
            }
            
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onChange(of: isFinished) {
            if isFinished {
                playSE(fileName: "2tap")
            }
        }
    }

    func checkInput() {
        guard !isFinished, currentWordIndex < stage.words.count else { return }
        
        let currentWord = wordList[currentWordIndex]
        let currentReading = currentWord.reading
        let expectedChar = currentReading[currentReading.index(currentReading.startIndex, offsetBy: currentCharIndex)]

        if !timerStarted {
            startTimer()
            timerStarted = true
        }

        if userInput.suffix(1) == String(expectedChar) {
            currentCharIndex += 1
            totalCharNum += 1
            userInput = ""
            wrongInput = ""

            if currentCharIndex >= currentWord.reading.count {
                currentWordIndex += 1
                currentCharIndex = 0

                if currentWordIndex >= wordList.count {
                    isAllClear = true
                    endGame()
                }
            }
        } else {
            wrongInput = userInput
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
                if timeRemaining <= 0 {
                    timeRemaining = 0
                    endGame()
                }
            }
        }
    }


    func endGame() {
        isFinished = true
        isInputFocused = false
        timer?.invalidate()

        if isAllClear {
            saveClearState()
        }

        let previousTotal = UserDefaults.standard.integer(forKey: "totalCorrect")
        let newTotal = previousTotal + totalCharNum
        UserDefaults.standard.set(newTotal, forKey: "totalCorrect")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            onFinish(currentWordIndex, totalCharNum)
        }
    }

    func saveClearState() {
        let key = "clearedStages_\(stage.category.rawValue)"
        var cleared = Set(UserDefaults.standard.array(forKey: key) as? [Int] ?? [])
        if !cleared.contains(stage.id) {
            cleared.insert(stage.id)
            UserDefaults.standard.set(Array(cleared), forKey: key)
        }
    }
}

