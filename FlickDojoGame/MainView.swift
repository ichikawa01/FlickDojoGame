//
//  MainView.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/06.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


enum AppScreen {
    case start
    case modeSelect
    case categorySelect
    
    case game
    
    case stageSelect
    case stageGame
    
    case result
    
    case status
    case nameEdit
    case ranking
}

struct MainView: View {
    @State private var currentScreen: AppScreen = .start
    @State private var showFade = false

    @State private var selectedMode: QuizMode = .timeLimit
    @State private var selectedCategory: QuizCategory = .level_1
    @State private var score: Int = 0
    @State private var characterCount: Int = 0
    @State private var selectedStage: Stage? = nil // ← ステージモード用



    var body: some View {
        ZStack {
            switch currentScreen {
                
            case .start:
                StartView(
                    onNext: {
                        transition(to: .modeSelect)
                    }
                )
                
                
            case .modeSelect:
                ModeSelectView (
                    onNext: { mode in
                        selectedMode = mode
                        transition(to: .categorySelect)
                    },
                    onBack: {
                        transition(to: .start)
                    },
                    onStatus: {
                        transition(to: .status)
                    }
                )
                
            case .categorySelect:
                CategorySelectView (
                    selectedMode: selectedMode,
                    onNext: { category in
                        selectedCategory = category
                        if selectedMode == .timeLimit {
                            transition(to: .game)
                        } else if selectedMode == .stageMode {
                            transition(to: .stageSelect)
                        }
                    },
                    onBack: {
                        transition(to: .modeSelect)
                    },
                    onStatus: {
                        transition(to: .status)
                    }
                )
                
            case .stageSelect:
                StageSelectView(
                    category: selectedCategory,
                    onSelectStage: { stage in
                        selectedStage = stage
                        transition(to: .stageGame)
                    },
                    onBack: {
                        transition(to: .categorySelect)
                    }
                )
                
            case .stageGame:
                if let stage = selectedStage {
                    StageGameView(
                        stage: stage,
                        onFinish: { wordCount, charCount in
                            score = wordCount
                            characterCount = charCount
                            transition(to: .result)
                        }
                    )
                }
                
            case .game:
                GameView (
                    mode: selectedMode,
                    category: selectedCategory,
                    onFinish: { wordCount, charCount in
                        score = wordCount
                        characterCount = charCount
                        transition(to: .result)
                    }
                )
                
            case .result:
                ResultView(
                    score: score,
                    characterCount: characterCount,
                    mode: selectedMode,
                    onNext: {
                        transition(to: .modeSelect)
                    },
                    onRanking: {
                        transition(to: .ranking)
                    }
                )
                
            case .status:
                if let userId = Auth.auth().currentUser?.uid {
                    StatusView(
                        userId: userId,
                        onBack: {
                            transition(to: .modeSelect)
                        },
                        onEditName: {
                            transition(to: .nameEdit)
                        },
                        onRanking: {
                            transition(to: .ranking)
                        }
                    )
                }
                
            case .nameEdit:
                if let userId = Auth.auth().currentUser?.uid {
                    NameEditView(
                        userId: userId,
                        onClose: {
                            transition(to: .status)
                        },
                        onBack: {
                            transition(to: .modeSelect)
                        }
                    )
                }
                
            case .ranking:
                RankingView(
                    onBack: {
                        transition(to: .modeSelect)
                    }
                )
                
                
                
            }// end switch


            if showFade {
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showFade)

    }
    

    func transition(to next: AppScreen) {
        withAnimation {
            showFade = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                currentScreen = next
                showFade = false
            }
        }
    }
    
    
}


#Preview {
    MainView()
}
