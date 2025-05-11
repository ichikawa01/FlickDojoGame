//
//  UserManager.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/08.
//

import Foundation
import FirebaseFirestore

class UserManager {
    static let shared = UserManager()
    private let db = Firestore.firestore()

    /// Firestoreからユーザー名を取得
    func getUserName(userId: String, completion: @escaping (String) -> Void) {
        let ref = db.collection("users").document(userId)
        ref.getDocument { document, error in
            if let document = document,
               let data = document.data(),
               let userName = data["userName"] as? String,
               !userName.trimmingCharacters(in: .whitespaces).isEmpty {
                completion(userName)
            } else {
                completion("匿名") // 名前がない or エラー時のデフォルト
            }
        }
    }
}

