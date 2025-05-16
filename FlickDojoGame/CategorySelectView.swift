//
//  CategorySelectView.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/06.
//

import SwiftUI
import GoogleMobileAds

struct CategorySelectView: View {
    
    @State private var flashNoTicket: Bool = false
    @State private var ticketCount: Int = {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "ticketCount") == nil {
            return 5 // 初回
        } else {
            return defaults.integer(forKey: "ticketCount")
        }
    }()


    
    @State private var isPaused = false

    let selectedMode: QuizMode
    
    let onNext: (QuizCategory) -> Void
    let onBack: () -> Void
    let onStatus: () -> Void
    
    let ticketKey = "ticketCount"
    let lastResetKey = "lastResetDate"

    func showRewardAd() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else {
            return
        }
        AdMobManager.shared.showAd(from: rootVC) {
            ticketCount = 5
            UserDefaults.standard.set(ticketCount, forKey: ticketKey)
        }
    }
    
    var body: some View {
        ZStack{
            
            if selectedMode == .timeLimit{
                //背景
                Image(.flickMeijin)
                    .resizable()
                    .ignoresSafeArea()
            } else if selectedMode == .stageMode{
                //背景
                Image(.flickDojo)
                    .resizable()
                    .ignoresSafeArea()
            }
            
            
            VStack{
                Spacer().frame(height: 15)
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
                    // ステータスボタン
                    Button(action: {
                        playSE(fileName: "1tap")
                        onStatus()
                    }) {
                        Image(.menu)
                            .resizable()
                            .frame(width: 45, height: 45)
                            .padding(.trailing, 25)
                    }
                }
                Spacer()
            }
            
            VStack(spacing: 10) {
                
                
                // チケット関連
                Spacer().frame(height: 300)
                if selectedMode == .timeLimit {
                    Button(action: {
                        playSE(fileName: "1tap")
                        isPaused = true
                    }) {
                        Text("チケット全回復")
                            .foregroundColor(.white)
                            .frame(width: 140, height: 40)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    if flashNoTicket {
                        Text("チケット: \(ticketCount)/5")
                            .foregroundColor(.red)
                            .font(.title3)
                    } else {
                        Text("チケット: \(ticketCount)/5")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                } else if selectedMode == .stageMode{
                    Spacer().frame(height: 80)
                }
                
                
                ForEach(QuizCategory.allCases, id: \.self) { category in
                    
                    Button(action: {
                        
                        if selectedMode == .timeLimit && ticketCount > 0 {
                            playSE(fileName: "1tap")
                            ticketCount -= 1
                            UserDefaults.standard.set(ticketCount, forKey: ticketKey)
                            onNext(category)
                            
                        } else if selectedMode == .timeLimit {
                            withAnimation {
                                playSE(fileName: "Ticket")
                                flashNoTicket = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation {
                                    flashNoTicket = false
                                }
                            }
                        } else {
                            playSE(fileName: "1tap")
                            onNext(category)
                        }
                        
                    }) {
                        switch category {
                        case .level_1:
                            Image(.woodLevel1)
                                .resizable()
                                .frame(width: 143, height: 65)
                        case .level_2:
                            Image(.woodLevel2)
                                .resizable()
                                .frame(width: 143, height: 65)
                        case .level_3:
                            Image(.woodLevel3)
                                .resizable()
                                .frame(width: 143, height: 65)
                        }
                    }
                }
                
                Spacer()
                
                CachedBannerView.shared
                    .frame(width: GADAdSizeLargeBanner.size.width, height: GADAdSizeLargeBanner.size.height)
                
            }
            
            // リワード広告確認
            if isPaused {
                Color.black.opacity(0.8)
                    .frame(width: 350, height: 250)
                VStack{
                    
                    Spacer()
                    
                    Text("動画を見てチケット全回復！！")
                        .font(.title2)
                        .foregroundStyle(Color.white)
                        .padding(.bottom, 25)
                        .bold()
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            playSE(fileName: "Ticket")
                            isPaused = false
                        }) {
                            Text("キャンセル")
                                .font(.title3)
                                .padding()
                                .frame(width: 130)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        Button(action: {
                            playSE(fileName: "2tap")
                            showRewardAd()
                            isPaused = false
                        }) {
                            Text("動画を見る")
                                .font(.title3)
                                .padding()
                                .frame(width: 130)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .bold()
                        }
                        
                    }
                    Spacer()
                }
            }
            
            
        }
        .onAppear {
            AdMobManager.shared.loadAd()
            restoreTicketIfNeeded()
        }
    }
    
    // チケット初期化・復元
    func restoreTicketIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastReset = UserDefaults.standard.object(forKey: lastResetKey) as? Date
        
        if lastReset == nil || lastReset! < today {
            ticketCount = 5
            UserDefaults.standard.set(today, forKey: lastResetKey)
            UserDefaults.standard.set(ticketCount, forKey: ticketKey)
        } else {
            let saved = UserDefaults.standard.integer(forKey: ticketKey)
            ticketCount = saved
        }
    }
    
    
    
}

#Preview {
    CategorySelectView(
        selectedMode: .stageMode,
        onNext: { _ in },
        onBack: {},
        onStatus: {}
    )
}
