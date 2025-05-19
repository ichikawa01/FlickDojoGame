//
//  Untitled.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/19.
//

import GoogleMobileAds
import UIKit

class InterstitialAd: NSObject, GADFullScreenContentDelegate {
    private var interstitial: GADInterstitialAd?
    var adUnitID: String

    init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init()
        loadAd()
    }

    func loadAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Interstitial failed to load: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
        }
    }

    func showAd(from root: UIViewController) {
        if let ad = interstitial {
            ad.present(fromRootViewController: root)
        } else {
            print("Ad not ready")
            loadAd() // 再読み込み
        }
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadAd() // 閉じられたら再読み込み
    }
}
