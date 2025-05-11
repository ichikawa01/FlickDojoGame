//
//  AuthManager.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/08.
//

import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()

    private init() {}

    // アプリ起動時にユーザーIDを自動で取得
    func signInIfNeeded(completion: @escaping (String?) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            completion(currentUser.uid)
        } else {
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    print("匿名ログイン失敗: \(error)")
                    completion(nil)
                } else {
                    print("匿名ログイン成功: \(result?.user.uid ?? "なし")")
                    completion(result?.user.uid)
                }
            }
        }
    }
}

