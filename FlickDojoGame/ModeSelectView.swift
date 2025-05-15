//
//  ModeSelectView.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/06.
//

import SwiftUI
import GoogleMobileAds


struct ModeSelectView: View {
//    @AppStorage("totalCorrect") var totalCorrect: Int = 200
    var totalCorrect: Int = 20000

    
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
                Spacer().frame(height: 10)
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
            
            
            VStack {
                
                Spacer().frame(height: 370)
                
                let rank = Kaikyu.getKaikyu(for: totalCorrect)
                let nextThreshold = Kaikyu.nextThreshold(for: totalCorrect)
                let remaining = nextThreshold.map { $0 - totalCorrect }
                ZStack{
                    switch rank {
                    case .minarai:
                        Image(.rank01)
                            .resizable()
                            .frame(width: 200, height: 34)
                    case .shugyochu:
                        Image(.rank02)
                            .resizable()
                            .frame(width: 200, height: 40)
                    case .shodan:
                        Image(.rank03)
                            .resizable()
                            .frame(width: 200, height: 35)
                    case .nidan:
                        Image(.rank04)
                            .resizable()
                            .frame(width: 200, height: 35)
                    case .sandan:
                        Image(.rank05)
                            .resizable()
                            .frame(width: 200, height: 35)
                    case .yondan:
                        Image(.rank06)
                            .resizable()
                            .frame(width: 200, height: 35)
                    case .godan:
                        Image(.rank07)
                            .resizable()
                            .frame(width: 200, height: 35)
                    case .shisho:
                        Image(.rank08)
                            .resizable()
                            .frame(width: 250, height: 50)
                    case .pro:
                        Image(.rank09)
                            .resizable()
                            .frame(width: 250, height: 50)
                    case .kami:
                        Image(.rank10)
                            .resizable()
                            .frame(width: 250, height: 60)
                    }
                    
                }
                
                
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
                        playSE(fileName: "1tap")
                        onNext(mode)
                    }) {
                        switch mode {
                        case .stageMode:
                            Image(.woodSyugyo)
                                .resizable()
                                .frame(width: 150, height: 70)
                                .padding(.bottom, 10)
                        case .timeLimit:
                            Image(.woodTime)
                                .resizable()
                                .frame(width: 150, height: 70)
                        }
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
        onNext: { _ in },
        onBack: {},
        onStatus: {}
    )
}

