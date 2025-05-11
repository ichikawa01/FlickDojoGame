//
//  AdMobManager.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/11.
//

import GoogleMobileAds
import UIKit

class AdMobManager: NSObject, GADFullScreenContentDelegate, ObservableObject {
    static let shared = AdMobManager()
    
    private var rewardAd: GADRewardedAd?
    private var onReward: (() -> Void)?
    
    func loadAd() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/5224354917", request: request) { ad, error in
            if let ad = ad {
                self.rewardAd = ad
                self.rewardAd?.fullScreenContentDelegate = self
            } else {
                print("広告読み込み失敗: \(error?.localizedDescription ?? "不明")")
            }
        }
    }
    
    func showAd(from rootViewController: UIViewController, onReward: @escaping () -> Void) {
        guard let ad = rewardAd else {
            print("広告が読み込まれていません")
            return
        }
        self.onReward = onReward
        ad.present(fromRootViewController: rootViewController) {
            onReward()
            self.loadAd()
        }
    }
}
