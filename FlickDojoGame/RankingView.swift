//
//  RankingView.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/08.
//

import SwiftUI
import FirebaseAuth

struct RankingView: View {
    @State private var selectedMode: QuizModeRank = .level_1
    @State private var selectedPeriod: RankingPeriod = .daily
    @State private var rankings: [RankingEntry] = []
    @State private var isLoading = false
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    let onBack: () -> Void
    
    var body: some View {
        
        ZStack{
            
            //背景
            Image(.gameback)
                .resizable()
                .ignoresSafeArea()
                .opacity(0.5)
            
            VStack {
                
                HStack{
                    // 戻るボタン（左上）
                    Button(action: {
                        playSE(fileName: "1tap")
                        onBack()
                    }) {
                        Image(.backIconWhite)
                            .resizable()
                            .frame(width: 45, height: 45)
                            .padding(.leading, 20)
                    }
                    Spacer()
                    if selectedPeriod == .daily {
                        Text("10分毎に更新")
                            .padding(.trailing, 15)
                    } else {
                        Text("翌日に更新")
                            .padding(.trailing, 15)
                    }

                }
                
                // モード選択
                Picker("モード", selection: $selectedMode) {
                    Text("初級").tag(QuizModeRank.level_1)
                    Text("中級").tag(QuizModeRank.level_2)
                    Text("上級").tag(QuizModeRank.level_3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 期間選択
                Picker("期間", selection: $selectedPeriod) {
                    Text("今日").tag(RankingPeriod.daily)
                    Text("今週").tag(RankingPeriod.weekly)
                    Text("今月").tag(RankingPeriod.monthly)
                    Text("累計").tag(RankingPeriod.total)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                
                // ランキング読み込み
                Button(action: {
                    playSE(fileName: "loading")
                    loadRankings()
                }) {
                    Text("ランキングを読み込む")
                        .foregroundColor(.white)
                        .padding()
                }
                
                // ランキング一覧
                if isLoading {
                    Color.white.opacity(0.6)
                        .ignoresSafeArea()
                    ProgressView()
                        .padding()
                } else if rankings.isEmpty {
                    Text("ランキングが見つかりません")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(Array(rankings.prefix(100).enumerated()), id: \.element.userId) { index, entry in
                            RankingRowView(index: index, entry: entry, currentUserId: currentUserId)
                        }
                    }
                    .scrollContentBackground(.hidden) // ← これで背景を消す！

                }
            }
            .navigationTitle("ランキング")
            .onAppear {
                loadRankings()
                BGMManager.shared.play(fileName: "ending")
            }
            .onDisappear {
                BGMManager.shared.play(fileName: "home")
            }
            .onChange(of: selectedMode) { loadRankings() }
            .onChange(of: selectedPeriod) { loadRankings() }
        }
        
        
    }
        
    func loadRankings() {
            isLoading = true
            RankingManager.shared.fetchTopRankings(mode: selectedMode, period: selectedPeriod) { result in
                rankings = result
                isLoading = false
            }
        }
    
    
}

#Preview {
    RankingView(
        onBack: {}
    )
}
