//
//  BannerAdView.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/10.
//

import SwiftUI
import GoogleMobileAds

// キャッシュされた BannerView をラップする SwiftUI View
struct CachedBannerView: UIViewRepresentable {
    static let shared = CachedBannerView()  // ← シングルトンとして保持OK

    private static var cachedBanner: BannerView?
    private static var refreshTimer: Timer?

    func makeUIView(context: Context) -> BannerView {
        if let existingBanner = CachedBannerView.cachedBanner {
            return existingBanner
        }

        let adSize = AdSizeLargeBanner
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = "ca-app-pub-7316649907762779/1687824442"

        if let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController {

            banner.rootViewController = rootVC
            banner.load(Request())

            // バナーをキャッシュ
            CachedBannerView.cachedBanner = banner

            // 1分ごとに再読み込み
            CachedBannerView.refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                banner.load(Request())
            }

            return banner
        } else {
            return banner // rootVC 取れなかった場合でも返す
        }
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
