//
//  SoundSettings.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/18.
//

import Foundation
import Combine

class SoundSettingsManager: ObservableObject {
    static let shared = SoundSettingsManager()
    
    @Published var isBgmOn: Bool {
        didSet {
            UserDefaults.standard.set(isBgmOn, forKey: "isBgmOn")
            applyBgmSetting()
        }
    }

    @Published var isSeOn: Bool {
        didSet {
            UserDefaults.standard.set(isSeOn, forKey: "isSeOn")
        }
    }

    private init() {
        self.isBgmOn = UserDefaults.standard.object(forKey: "isBgmOn") as? Bool ?? true
        self.isSeOn = UserDefaults.standard.object(forKey: "isSeOn") as? Bool ?? true
        applyBgmSetting()
    }

    private func applyBgmSetting() {
        if isBgmOn {
            BGMManager.shared.resume()
        } else {
            BGMManager.shared.stop()
        }
    }
}
