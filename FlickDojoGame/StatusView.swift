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
    
    @EnvironmentObject var soundSettings: SoundSettingsManager
    @ObservedObject var purchaseManager = PurchaseManager.shared
    
    @AppStorage("isBgmOn") private var isBgmOn: Bool = true
    @AppStorage("isSeOn") private var isSeOn: Bool = true
    
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
                        if soundSettings.isBgmOn {
                            BGMManager.shared.play(fileName: "home")
                        } else {
                            BGMManager.shared.stop()
                        }
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
                                
                // 課金ボタン
                HStack {
                    Button(action: {
                        Task {
                            await PurchaseManager.shared.purchaseRemoveAds()
                        }
                    }) {
                        Text("広告を削除（￥160）")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 40)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Button(action: {
                        Task {
                            await PurchaseManager.shared.restorePurchases()
                        }
                    }) {
                        Text("購入を復元")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 130, height: 40)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                

                
                // ⚙️ ここにBGM・SEスイッチを横並びで追加
                HStack(spacing: 40) {
                    Toggle("BGM", isOn: $soundSettings.isBgmOn)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .onChange(of: isBgmOn) {
                            if isBgmOn {
                                BGMManager.shared.play(fileName: "ending")
                            } else {
                                BGMManager.shared.stop()
                            }
                        }
                    
                    Toggle("効果音", isOn: $soundSettings.isSeOn)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                .padding(.horizontal)
                .frame(maxWidth: 300)
                
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
                
                
                if !purchaseManager.isAdRemoved {
                    CachedBannerView.shared
                        .frame(width: GADAdSizeLargeBanner.size.width, height: GADAdSizeLargeBanner.size.height)
                }
                
            }
        }
        .onAppear {
            if soundSettings.isBgmOn {
                BGMManager.shared.play(fileName: "ending")
            } else {
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
    }
}

#Preview {
    StatusView(userId: "", onBack: {}, onEditName: {}, onRanking: {})
}
