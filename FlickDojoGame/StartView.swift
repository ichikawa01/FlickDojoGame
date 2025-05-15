//
//  StartView.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/06.
//

// StartView.swift
import SwiftUI
import FirebaseFirestore

struct StartView: View {
    
    // ユーザーネーム関連
    @State private var isEnteringName = false
    @State private var userId: String? = nil
    @AppStorage("hasEnteredName") private var hasEnteredName = false
    
    @State private var selectedCategory: QuizCategory = .level_1
    @State private var selectedMode: QuizMode = .timeLimit
    
    let onNext: () -> Void
        
    var body: some View {
        if isEnteringName, let uid = userId {
            NameInputView (
                userId: uid,
                onComplete: {
                    hasEnteredName = true
                    isEnteringName = false
                    onNext()
                },
                onBack: {
                    isEnteringName = false
                }
            )
        } else {
            mainStartView
        }
    }

    
    var mainStartView: some View {
        ZStack {
            
            // 背景
            Image(.flickMeijin)
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                
                Spacer().frame(height: 330)

                // 初回は名前の入力、次回以降はonNext()
                Button(action: {
                    playSE(fileName: "2tap")
                    AuthManager.shared.signInIfNeeded { uid in
                        self.userId = uid
                        if let uid = userId {
                            
                            checkIfUserNameExists(userId: uid) { exists in
                                if exists {
                                    hasEnteredName = true // 念のため同期
                                    print("ユーザー存在確認")
                                    onNext()
                                } else {
                                    isEnteringName = true
                                }
                            }
                            
                        }
                    }
                }) {
                    Image(.woodStart)
                        .resizable()
                        .frame(width: 210, height: 100)
//                    Text("挑戦")
//                        .font(.largeTitle)
//                        .foregroundColor(.white)
//                        .bold()
//                        .padding()
//                        .frame(width: 200, height: 60)
//                        .background(Color.startBtn)
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                
            }
        }
    }
    
    
    // ユーザーがfirebaseに登録されているか確認
    func checkIfUserNameExists(userId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userId)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                let name = document.data()?["userName"] as? String
                completion(name?.isEmpty == false)
            } else {
                completion(false)
            }
        }
    }

}

#Preview {
    StartView(
        onNext: {})
}

