//
//  NameInputView.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/08.
//

import SwiftUI
import FirebaseFirestore

struct NameInputView: View {
    @State private var name = ""
    @FocusState private var isInputFocused: Bool

    var userId: String
    
    var onComplete: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack{
            
            // 背景
            Image(.gameback)
                .resizable()
                .ignoresSafeArea()
            
            VStack{
                HStack{
                    // 戻るボタン（左上）
                    Button(action: {
                        isInputFocused = false
                        onBack()
                    }) {
                        Image(.backIconWhite)
                            .resizable()
                            .frame(width: 45, height: 45)
                            .padding(.leading, 40)
                    }
                    Spacer()
                }
                Spacer()
            }
            
            VStack(spacing: 20) {
                Text("ニックネームを入力")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(Color.black)
                Text("いつでも変更できます")
                    .font(.title3)
                    .foregroundStyle(Color.black)
                
                ZStack{
                    
                    Image(.makimono)
                        .resizable()
                        .ignoresSafeArea()
                        .frame(width: 400, height: 120)
                    
                    TextField("", text: $name)
                        .focused($isInputFocused)
                        .textFieldStyle(PlainTextFieldStyle())
                        .frame(width: 240)
                        .padding(.horizontal, 80)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .font(.system(size: 24))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                isInputFocused = true
                            }
                        }
                        .onChange(of: name) {
                            if name.count > 10 {
                                name = String(name.prefix(10)) // 10文字に切り詰める
                            }
                        }
                }
                
                Button("決定") {
                    isInputFocused = false
                    saveUserName(userId: userId, name: name)
                    onComplete()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                .font(.largeTitle)
                .foregroundColor(.white)
                .bold()
                .padding()
                .frame(width: 200, height: 60)
                .background(Color.startBtn)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            }
        }
        
        
        
    }

    func saveUserName(userId: String, name: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData([
            "userName": name
        ], merge: true)
    }


#Preview {
    NameInputView(
        userId: "test",
        onComplete: {},
        onBack: {}
    )
}
