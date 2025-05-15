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
                        playSE(fileName: "1tap")
                        BGMManager.shared.play(fileName: "home")
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
                        .frame(width:320, height: 110)
                    
                    Text("道場の記録")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(Color.black)
                }
                
                Spacer().frame(height: 10)
                
                Button(action: {
                    playSE(fileName: "1tap")
                    onEditName()
                }) {
                    Text("名前を変更")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 260, height: 60)
                        .background(Color.startBtn)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button(action: {
                    playSE(fileName: "1tap")
                    onRanking()
                }) {
                    Text("ランキング")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 260, height: 60)
                        .background(Color.startBtn)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()
                
                CachedBannerView.shared
                    .frame(width: GADAdSizeLargeBanner.size.width, height: GADAdSizeLargeBanner.size.height)

            }
        }
        .onAppear {
            BGMManager.shared.play(fileName: "ending")
        }
    }
}

#Preview {
    StatusView(userId: "", onBack: {}, onEditName: {}, onRanking: {})
}
