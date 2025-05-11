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
                        transition(to: .game)
                    },
                    onBack: {
                        transition(to: .modeSelect)
                    },
                    onStatus: {
                        transition(to: .status)
                    }
                )
                
            case .game:
                GameView (
                    mode: selectedMode,
                    category: selectedCategory,
                    onFinish: { wordCount, charCount in
                        score = wordCount
                        characterCount = charCount
                        transition(to: .result)
                    },
                    onBack: {
                        transition(to: .start)
                    }
                )
                
            case .result:
                ResultView(
                    score: score,
                    characterCount: characterCount,
                    mode: selectedMode,
                    onNext: {
                        transition(to: .start)
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
                            transition(to: .start)
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
                            transition(to: .start)
                        }
                    )
                }
                
            case .ranking:
                RankingView(
                    onBack: {
                        transition(to: .start)
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
