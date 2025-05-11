//
//  BannerAdView.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/10.
//

import SwiftUI
import GoogleMobileAds

// キャッシュされた GADBannerView をラップする SwiftUI View
struct CachedBannerView: UIViewRepresentable {
    static let shared = CachedBannerView()  // ← シングルトンとして保持OK

    private static var cachedBanner: GADBannerView?

    func makeUIView(context: Context) -> GADBannerView {
        if let existingBanner = CachedBannerView.cachedBanner {
            print("♻️ 再利用バナー")
            return existingBanner
        }

        let adSize = GADAdSizeLargeBanner
        let banner = GADBannerView(adSize: adSize)
        banner.adUnitID = "ca-app-pub-3940256099942544/2435281174"

        if let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController {

            banner.rootViewController = rootVC
            banner.load(GADRequest())
            print("✅ バナー初回読み込み")

            CachedBannerView.cachedBanner = banner
            return banner
        } else {
            print("⚠️ rootViewController 取得失敗")
            return banner // 空でも返す
        }
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}

