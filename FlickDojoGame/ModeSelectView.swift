//
//  ModeSelectView.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/06.
//

import SwiftUI
import GoogleMobileAds


struct ModeSelectView: View {
    @AppStorage("totalCorrect") var totalCorrect: Int = 0

    
    let onNext: (QuizMode) -> Void
    let onBack: () -> Void
    let onStatus: () -> Void

    
    var body: some View {
        ZStack{

            //背景
            Image(.flickMeijin)
                .resizable()
                .ignoresSafeArea()
            
            VStack{
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
                    // 初回は名前の入力、次回以降はonStatus()
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
                
                Spacer().frame(height: 370)
                
                let rank = Kaikyu.getKaikyu(for: totalCorrect)
                let nextThreshold = Kaikyu.nextThreshold(for: totalCorrect)
                let remaining = nextThreshold.map { $0 - totalCorrect }
                
                Text("現在の称号：\(rank.rawValue)：\(totalCorrect)")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.gray)
                    .background(Color.black)
                    .frame(height: 0)
                
                if let remaining = remaining {
                    Text("次の称号まで残り \(remaining) 文字")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray)
                        .background(Color.black)
                        .padding(.bottom, 20)
                } else {
                    Text("最高称号に到達！")
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                        .padding(.bottom, 20)
                }
                
                
                ForEach(QuizMode.allCases, id: \.self) { mode in
                    Button(action: {
                        onNext(mode)
                    }) {
                        Text(mode.description)
                            .font(.title3)
                            .bold()
                            .frame(width: 160, height: 60)
                            .background(Color.startBtn)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                }
                
                Spacer()
                
                CachedBannerView.shared
                    .frame(width: GADAdSizeLargeBanner.size.width, height: GADAdSizeLargeBanner.size.height)
            }
        }
        
    }
}

#Preview {
    ModeSelectView(
//        totalCorrect: 1,
        onNext: { _ in },
        onBack: {},
        onStatus: {}
    )
}

