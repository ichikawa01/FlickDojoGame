//
//  ScoreManager.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/07.
//


import Foundation
import FirebaseFirestore

class ScoreManager {
    static let shared = ScoreManager()
    private let db = Firestore.firestore()

    private init() {}

    func submitScore(userId: String, score: Int) {
        db.collection("rankings").addDocument(data: [
            "userId": userId,
            "score": score,
            "timestamp": Timestamp()
        ]) { error in
            if let error = error {
                print("スコア送信失敗: \(error.localizedDescription)")
            } else {
                print("スコア送信成功！ユーザーID: \(userId)")
            }
        }
    }
}
