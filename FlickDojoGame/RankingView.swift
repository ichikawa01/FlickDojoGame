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
    @State private var lastReads: [String: String] = [:] // [mode_period: 時間キー]
    
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    // リワード広告でランキングを変更（Top10 or Top300）今は100にしておく
    var visibleEntries: ArraySlice<RankingEntry> {
        rankings.prefix(100)
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
                        onBack()
                    }) {
                        Image(.backIconWhite)
                            .resizable()
                            .frame(width: 45, height: 45)
                            .padding(.leading, 20)
                    }
                    Spacer()
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
                        ForEach(Array(visibleEntries.enumerated()), id: \.element.userId) { index, entry in
                            RankingRowView(index: index, entry: entry, currentUserId: currentUserId)
                        }
                    }
                    .scrollContentBackground(.hidden) // ← これで背景を消す！

                }
            }
            .navigationTitle("ランキング")
            .onAppear {
                loadRankings()
                AdMobManager.shared.loadAd() // リワード広告読み込み
            }
            .onChange(of: selectedMode) { loadRankings() }
            .onChange(of: selectedPeriod) { loadRankings() }
        }
        
        
    }
        

    func loadRankings() {
        let now = Date()
        let jst = TimeZone(identifier: "Asia/Tokyo")!
        let calendar = Calendar(identifier: .gregorian)
        var jstCalendar = calendar
        jstCalendar.timeZone = jst
        
        let components = jstCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        
        let key: String
        if selectedPeriod == .daily {
            let fiveMinuteMark = (components.minute! / 5) * 5
            key = String(format: "%04d%02d%02d_%02d%02d",
                         components.year ?? 0,
                         components.month ?? 0,
                         components.day ?? 0,
                         components.hour ?? 0,
                         fiveMinuteMark)
        } else {
            key = String(format: "%04d%02d%02d",
                         components.year ?? 0,
                         components.month ?? 0,
                         components.day ?? 0)
        }
        
        let modePeriodKey = "\(selectedMode.rawValue)_\(selectedPeriod.rawValue)"
        
        if lastReads[modePeriodKey] == key {
            print("同じキーのため、読み取りスキップ：\(key)")
            return
        }
        
        lastReads[modePeriodKey] = key
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
