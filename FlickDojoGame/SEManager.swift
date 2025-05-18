//
//  SEManager.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/15.
//

import Foundation
import AVFoundation
import SwiftUI

var sePlayer: AVAudioPlayer?

func playSE(fileName: String) {
    if !SoundSettingsManager.shared.isSeOn { return } // ← ここを追加！

    if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
        do {
            sePlayer = try AVAudioPlayer(contentsOf: url)
            sePlayer?.prepareToPlay()
            sePlayer?.play()
        } catch {
            print("SE再生エラー: \(error)")
        }
    }
}
