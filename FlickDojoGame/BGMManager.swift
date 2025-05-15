//
//  BGMManager.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/15.
//

import Foundation
import AVFoundation

class BGMManager: ObservableObject {
    static let shared = BGMManager()
    
    private var player: AVAudioPlayer?
    private var currentFileName: String?

    private init() {}

    func play(fileName: String) {
        // 同じBGMなら再生し直さない
        if currentFileName == fileName {
            return
        }
        stop()
        currentFileName = fileName

        if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.volume = 0.7
                player?.numberOfLoops = -1 // ループ再生
                player?.prepareToPlay()
                player?.play()
            } catch {
                print("BGM再生エラー: \(error)")
            }
        }
    }

    func stop() {
        player?.stop()
        player = nil
        currentFileName = nil
    }
}
