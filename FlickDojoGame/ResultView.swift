//
//  ResultView.swift
//
//  Created by 市川涼 on 2025/05/06.
//


import SwiftUI
import GoogleMobileAds
import StoreKit

struct ResultView: View {
    
    @State private var showScore = false
    @State private var showCharacters = false
    @State private var showButtons = false
    @State private var isSharing = false
    
    @State private var sessionPlayCount = 0
    private let interstitialAd = InterstitialAd(adUnitID: "ca-app-pub-3940256099942544/4411468910")

    
    @EnvironmentObject var soundSettings: SoundSettingsManager
    @ObservedObject var purchaseManager = PurchaseManager.shared


    func shareResult() {
        isSharing = true
    }
    
    
    func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func trackPlayCountAndMaybeRequestReview() {
        var playCount = UserDefaults.standard.integer(forKey: "playCount")
        playCount += 1
        UserDefaults.standard.set(playCount, forKey: "playCount")
        
        if playCount == 4 || playCount == 19 {
            requestReview()
        }
    }
    
    
    
    let score: Int
    let characterCount: Int
    let mode: QuizMode
    
    let onNext: () -> Void
    let onRanking: () -> Void
    
    
    var body: some View {
        
        
        ZStack{
            Image(.result)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                
                Spacer().frame(height: 210)
                
                // スコアの表示
                ZStack{
                    Image(.makimono)
                        .resizable()
                        .frame(width:330, height: 120)
                        .ignoresSafeArea()
                    
                    VStack{
                        if showScore{
                            Text(" \(score) 問クリア！")
                                .font(.largeTitle)
                                .foregroundStyle(Color.black)
                                .opacity(showScore ? 1 : 0)
                                .animation(.easeInOut, value: showScore)
                        }
                        
                        if showCharacters{
                            Text("合計 \(characterCount) 文字")
                                .font(.title2)
                                .foregroundStyle(Color.black)
                                .opacity(showCharacters ? 1 : 0)
                                .animation(.easeInOut, value: showCharacters)
                        }
                    }
                }
                
                Spacer().frame(height: 40)
                
                VStack (spacing: 30) {
                    
                    if mode == .timeLimit{
                        Button(action: {
                                    playSE(fileName: "1tap")
                            onRanking()
                        }) {
                            Text("ランキングへ")
                                .padding()
                                .font(.title3)
                                .bold()
                                .frame(width: 160, height: 60)
                                .foregroundColor(.white)
                                .background(Color.startBtn)
                                .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                            playSE(fileName: "1tap")
                        onNext()
                    }) {
                        Text("退場")
                            .padding()
                            .font(.title)
                            .bold()
                            .frame(width: 160, height: 60)
                            .foregroundColor(.white)
                            .background(Color.startBtn)
                            .cornerRadius(12)
                    }
                    Button(action: {
                            playSE(fileName: "1tap")
                        shareResult()
                    }) {
                        Text("結果を共有")
                            .padding()
                            .font(.title3)
                            .bold()
                            .frame(width: 160, height: 60)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                }
                .opacity(showButtons ? 1 : 0)
                .animation(.easeInOut, value: showButtons)
                
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
            trackPlayCountAndMaybeRequestReview()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                        playSE(fileName: "1tap")
                    showScore = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                        playSE(fileName: "1tap")
                    showCharacters = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                        playSE(fileName: "2tap")
                    showButtons = true
                }
            }
                        
            sessionPlayCount += 1
            print(sessionPlayCount)
            
            if sessionPlayCount == 2 && !purchaseManager.isAdRemoved {
                if let rootVC = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first?.windows
                    .first(where: { $0.isKeyWindow })?.rootViewController {
                    interstitialAd.showAd(from: rootVC)
                }
                sessionPlayCount = 0
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
        .sheet(isPresented: $isSharing) {
            let message = "\(score)問クリア！⭐️合計\(characterCount)文字！🔥\nあなたはこの記録超えられる？\nフリックの達人👇\nhttps://apps.apple.com/app/id00000000" // AppStoreURL
            ShareSheet(activityItems: [message])
        }
        
    }
    
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


#Preview {
    ResultView(
        score: 12,
        characterCount: 56,
        mode: .timeLimit,
        onNext: {},
        onRanking: {}
    )
    
}
