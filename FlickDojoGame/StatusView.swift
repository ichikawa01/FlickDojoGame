//
//  StatusView.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/08.
//
import SwiftUI
import GoogleMobileAds

struct StatusView: View {
    let userId: String
    let onBack: () -> Void
    let onEditName: () -> Void
    let onRanking:() -> Void
    
    var body: some View {
        ZStack {
            // 背景
            Image(.gameback)
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
                }
                Spacer()
            }
            

            VStack(spacing: 30) {
                
                Spacer().frame(height: 120)
                
                
                ZStack{
                    Image(.makimono)
                        .resizable()
                        .ignoresSafeArea()
                        .frame(width:400, height: 130)
                    
                    Text("道場の記録")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(Color.black)
                }
                
                Button("名前を変更") {
                    onEditName()
                }
                .font(.title)
                .foregroundColor(.white)
                .bold()
                .frame(width: 260, height: 60)
                .background(Color.startBtn)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("ランキング") {
                    onRanking()
                }
                .font(.title)
                .foregroundColor(.white)
                .bold()
                .frame(width: 260, height: 60)
                .background(Color.startBtn)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("称号") {
                    // 今後実装
                }
                .font(.title)
                .foregroundColor(.white)
                .bold()
                .frame(width: 260, height: 60)
                .background(Color.startBtn)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
                
                CachedBannerView.shared
                    .frame(width: GADAdSizeLargeBanner.size.width, height: GADAdSizeLargeBanner.size.height)

            }
        }
    }
}

#Preview {
    StatusView(userId: "", onBack: {}, onEditName: {}, onRanking: {})
}
