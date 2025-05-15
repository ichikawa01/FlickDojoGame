//
//  ResultView.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/06.
//


import SwiftUI
import GoogleMobileAds

struct ResultView: View {
    
    @State private var showScore = false
    @State private var showCharacters = false
    @State private var showButtons = false
    
    let score: Int
    let characterCount: Int
    let mode: QuizMode
    
    let onNext: () -> Void
    let onRanking: () -> Void


    var body: some View {
        
        ZStack{
            Image(.result)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                
                Spacer().frame(height: 210)
                
                // スコアの表示
                ZStack{
                    Image(.makimono)
                        .resizable()
                        .frame(width:320, height: 120)
                        .ignoresSafeArea()
                    
                    VStack{
                        if showScore{
                            Text(" \(score) 問クリア！")
                                .font(.largeTitle)
                                .foregroundStyle(Color.black)
                                .opacity(showScore ? 1 : 0)
                                .animation(.easeInOut, value: showScore)
                        }
                        
                        if showCharacters{
                            Text("合計 \(characterCount) 文字")
                                .font(.title2)
                                .foregroundStyle(Color.black)
                                .opacity(showCharacters ? 1 : 0)
                                .animation(.easeInOut, value: showCharacters)
                        }
                    }
                }
                
                Spacer().frame(height: 60)
                                
                VStack (spacing: 30) {
                    
                    if mode == .timeLimit{
                        Button(action: {
                            playSE(fileName: "1tap")
                            onRanking()
                        }) {
                            Text("ランキングへ")
                                .padding()
                                .font(.title3)
                                .bold()
                                .frame(width: 160, height: 60)
                                .foregroundColor(.white)
                                .background(Color.startBtn)
                                .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        playSE(fileName: "1tap")
                        onNext()
                    }) {
                        Text("退場")
                        .padding()
                        .font(.title)
                        .bold()
                        .frame(width: 160, height: 60)
                        .foregroundColor(.white)
                        .background(Color.startBtn)
                        .cornerRadius(12)
                    }
                }
                .opacity(showButtons ? 1 : 0)
                .animation(.easeInOut, value: showButtons)
                
                Spacer()

                CachedBannerView.shared
                    .frame(width: GADAdSizeLargeBanner.size.width, height: GADAdSizeLargeBanner.size.height)
            }
        }
        .onAppear {
            BGMManager.shared.play(fileName: "ending")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    playSE(fileName: "1tap")
                    showScore = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    playSE(fileName: "1tap")
                    showCharacters = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    playSE(fileName: "2tap")
                    showButtons = true
                }
            }
        }
        .onDisappear {
            BGMManager.shared.play(fileName: "home")
        }

        
    }
}

#Preview {
    ResultView(
        score: 12,
        characterCount: 56,
        mode: .timeLimit,
        onNext: {},
        onRanking: {}
    )
}
