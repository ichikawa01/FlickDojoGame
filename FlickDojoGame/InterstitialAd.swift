//
//  Untitled.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/19.
//

import GoogleMobileAds
import UIKit

class InterstitialAd: NSObject, FullScreenContentDelegate {
    private var interstitial: GoogleMobileAds.InterstitialAd?
    var adUnitID: String
    
    var onAdLoaded: (() -> Void)?


    init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init()
        loadAd()
    }

    func loadAd() {
        let request = GoogleMobileAds.Request()
        GoogleMobileAds.InterstitialAd.load(
            with: adUnitID,
            request: request
        ) { [weak self] ad, error in
            if let error = error {
                print("❌ Interstitial failed to load: \(error.localizedDescription)")
                return
            }

            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
            print("✅ Interstitial loaded")
            
            self?.onAdLoaded?()

        }
    }

    func showAd(from root: UIViewController) {
        if let ad = interstitial {
            ad.present(from: root)
        } else {
            print("Ad not ready")
            loadAd() // 再読み込み
        }
    }

    // MARK: - FullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Interstitial dismissed. Reloading...")
        loadAd()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Failed to present interstitial: \(error.localizedDescription)")
        loadAd()
    }
}
