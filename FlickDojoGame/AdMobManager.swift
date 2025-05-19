//
//  AdMobManager.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/11.
//

import GoogleMobileAds
import UIKit

class AdMobManager: NSObject, FullScreenContentDelegate, ObservableObject {
    static let shared = AdMobManager()
    
    private var rewardAd: RewardedAd?
    private var onReward: (() -> Void)?
    
    func loadAd() {
        let request = GoogleMobileAds.Request()
        RewardedAd.load(with: "ca-app-pub-7316649907762779/3387386096", request: request) { ad, error in
            if let ad = ad {
                self.rewardAd = ad
                self.rewardAd?.fullScreenContentDelegate = self
            }
        }
    }
    
    func showAd(from rootViewController: UIViewController, onReward: @escaping () -> Void) {
        guard let ad = rewardAd else {
            return
        }
        self.onReward = onReward
        ad.present(from: rootViewController) {
            onReward()
            self.loadAd()
        }
    }
}
