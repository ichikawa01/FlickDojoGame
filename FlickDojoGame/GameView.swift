//
//  GameView.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/06.
//


// GameView.swift
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct GameView: View {
    
    @State private var currentWordIndex = 0
    @State private var currentCharIndex = 0
    @State private var totalCharNum = 0
    @State private var timeRemaining = 20

    @State private var userInput = ""
    @State private var wrongInput = ""
    
    @State private var isFinished = false
    @State private var isAllClear = false
    @State private var timerStarted = false
    @State private var isPaused = false

    @FocusState private var isInputFocused: Bool
    
    @State private var timer: Timer? = nil
    
    let mode: QuizMode
    let category: QuizCategory
    let onFinish: (Int, Int) -> Void
    let wordList: [WordItem]
    
    // 時間の出力
    var timerText: String {
        if mode == .stageMode {
            return "回答数: \(currentWordIndex) 問"
        } else if mode == .timeLimit {
            return "残り時間: \(timeRemaining) 秒"
        } else {
            return ""
        }
    }
    
    // wordList(json)をlordWords.swiftから取得
    init(mode: QuizMode, category: QuizCategory, onFinish: @escaping (Int, Int) -> Void) {
        self.mode = mode
        self.category = category
        self.onFinish = onFinish
        self.wordList = loadWords(from: category).shuffled()
    }
    
    
    var body: some View {
        ZStack {
            //背景
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
                    
                    Text(timerText)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                }
                
                // 終了画面
                if isFinished {
                    
                    Text(isAllClear ? "全問クリア！" : "そこまで！")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.black)
                    
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

                    // キーボード関連
                    TextField("", text: $userInput)
                        .focused($isInputFocused)
                        .onSubmit {
                            isInputFocused = true
                        }
                        .onChange(of: userInput) {
                            checkInput()
                        }
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
        }// Zstack end
        
        
        
    }

    //
    var correctPart: String {
        String(wordList[currentWordIndex].reading.prefix(currentCharIndex))
    }

    // 入力された文字が正しいか判定
    func checkInput() {
        guard !isFinished, currentWordIndex < wordList.count else { return }
        let currentReading = wordList[currentWordIndex].reading
        let expectedChar = currentReading[currentReading.index(currentReading.startIndex, offsetBy: currentCharIndex)]
        
        // 文字が打たれたらタイマー開始
        if !timerStarted {
            startTimer()
            timerStarted = true
        }
        
        // 正解が入力された時の処理
        if userInput.suffix(1) == String(expectedChar) {
            currentCharIndex += 1
            totalCharNum += 1
            userInput = ""
            wrongInput = ""

            if currentCharIndex >= currentReading.count {
                currentWordIndex += 1
                currentCharIndex = 0
                
                if currentWordIndex >= wordList.count {
                    isAllClear = true
                    endGame()
                }
            }
        } else {
            // 間違いが入力された時の処理
            wrongInput = userInput
        }
    }
    
    // タイマーの開始
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if mode == .timeLimit {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    endGame()
                }
            }
        }
    }

    
    // ゲーム終了（全問正解、時間切れ）
    func endGame() {
        isFinished = true
        isInputFocused = false
        timer?.invalidate()
                
        // 累計正解数の保存
        let previousTotal = UserDefaults.standard.integer(forKey: "totalCorrect")
        let newTotal = previousTotal + totalCharNum
        UserDefaults.standard.set(newTotal, forKey: "totalCorrect")
        
        // スコアの送信
        AuthManager.shared.signInIfNeeded { userId in
            guard let userId = userId else { return }
            UserManager.shared.getUserName(userId: userId) { name in
                let quizRank: QuizModeRank = {
                    switch category {
                    case .level_1: return .level_1
                    case .level_2: return .level_2
                    case .level_3: return .level_3
                    }
                }()

                RankingManager.shared.submitScore(
                    userId: userId,
                    userName: name,
                    score: totalCharNum,
                    mode: quizRank
                )
            }
        }


        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            onFinish(currentWordIndex, totalCharNum)

        }

    }
    
}

#Preview {
    GameView(
        mode: .timeLimit,
        category: .level_3,
        onFinish: { _, _ in }
    )
}
