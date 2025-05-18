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
    
    @EnvironmentObject var soundSettings: SoundSettingsManager

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
                        Text("30分毎に更新")
                            .padding(.trailing, 15)
                    } else {
                        Text("9:00に更新")
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
                    ZStack {
                        // 背景の暗めオーバーレイ（画面全体）
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        // 中央の白いボックス
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                            Text("読み込み中...")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .padding(30)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    }
                }
                else if rankings.isEmpty {
                    Text("ランキングが見つかりません")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(Array(rankings.prefix(100).enumerated()), id: \.element.userId) { index, entry in
                            RankingRowView(index: index, entry: entry, currentUserId: currentUserId)
                                .listRowInsets(EdgeInsets(top: 4, leading: 5, bottom: 4, trailing: 5))
                                .frame(minHeight: 20)
                        }
                    }
                    .scrollContentBackground(.hidden) // ← これで背景を消す！
                    
                }
            }
            .navigationTitle("ランキング")
            .onAppear {
                loadRankings()
                if soundSettings.isBgmOn {
                    BGMManager.shared.play(fileName: "ending")
                } else{
                    BGMManager.shared.stop()
                }
            }
            .onChange(of: soundSettings.isBgmOn) {
                if soundSettings.isBgmOn {
                    BGMManager.shared.play(fileName: "ending")
                } else {
                    BGMManager.shared.stop()
                }
            }
            .onDisappear {
                if soundSettings.isBgmOn {
                    BGMManager.shared.play(fileName: "home")
                } else {
                    BGMManager.shared.stop()
                }
            }
            .onChange(of: selectedMode) { loadRankings() }
            .onChange(of: selectedPeriod) { loadRankings() }
        }
        
        
    }
    
    func loadRankings() {
        isLoading = true
        let minLoadingDuration: TimeInterval = 0.3
        let startTime = Date()
        
        RankingManager.shared.fetchTopRankings(mode: selectedMode, period: selectedPeriod) { result in
            let elapsed = Date().timeIntervalSince(startTime)
            let delay = max(0, minLoadingDuration - elapsed)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                rankings = result
                isLoading = false
            }
        }
    }
}

#Preview {
    RankingView(
        onBack: {}
    )
}
