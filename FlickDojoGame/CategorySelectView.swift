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
    @State private var ticketCount: Int = 5
    
    func showRewardAd() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else {
            return
        }
        AdMobManager.shared.showAd(from: rootVC) {
            ticketCount = 5
        }
    }

    let selectedMode: QuizMode
    
    let onNext: (QuizCategory) -> Void
    let onBack: () -> Void
    let onStatus: () -> Void

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
            
            VStack(spacing: 20) {
                
                
                // チケット関連
                Spacer().frame(height: 300)
                if selectedMode == .timeLimit {
                    Button("チケット全回復") {
                        showRewardAd()
                    }
                    .foregroundColor(.white)
                    .frame(width: 140, height: 40)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(4)
                    
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
                    
                    Button(category.title) {
                        
                        if selectedMode == .timeLimit && ticketCount > 0 {
                            ticketCount -= 1
                            onNext(category)
                            
                        } else if selectedMode == .timeLimit {
                            print("チケットがありません")
                            withAnimation {
                                flashNoTicket = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation {
                                    flashNoTicket = false
                                }
                            }
                        } else {
                            onNext(category)
                        }
                        
                    }
                    .padding()
                    .font(.title3)
                    .bold()
                    .frame(width: 160, height: 60)
                    .foregroundColor(.white)
                    .background(Color.startBtn)
                    .cornerRadius(12)
                }
                
                Spacer()
                
                CachedBannerView.shared
                    .frame(width: GADAdSizeLargeBanner.size.width, height: GADAdSizeLargeBanner.size.height)
                
            }
        }
        .onAppear {
            AdMobManager.shared.loadAd()
        }


        
    }
}

#Preview {
    CategorySelectView(
        selectedMode: .timeLimit,
        onNext: { _ in },
        onBack: {},
        onStatus: {}
    )
}
