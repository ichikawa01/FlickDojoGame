//
//  StageSelectView.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/12.
//

import SwiftUI

struct StageSelectView: View {
    let category: QuizCategory
    let onSelectStage: (Stage) -> Void
    let onBack: () -> Void

    @State private var clearedStages: Set<Int> = []
    @State private var stages: [Stage] = []

    var body: some View {
        
        ZStack{
            
            //背景
            Image(.gameback)
                .resizable()
                .ignoresSafeArea()
                .opacity(0.6)
            
            VStack{
                HStack{
                    // 戻るボタン（左上）
                    Button(action: {
                        onBack()
                    }) {
                        Image(.backIconWhite)
                            .resizable()
                            .frame(width: 45, height: 45)
                            .padding(.leading, 20)
                    }
                    Spacer()
                }
                Spacer()
            }
            
            
            VStack (spacing: 20){
                Text("\(category.title) ステージ選択")
                    .font(.title)
                    .foregroundStyle(Color.white)
                    .bold()
                    .padding()
                Text("ステージ数: \(stages.count)") // ← 表示されるかチェック
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                        ForEach(stages, id: \.id) { stage in
                            StageButton(stage: stage, clearedStages: clearedStages, onSelectStage: onSelectStage)
                        }
                    }
                }
            }
            .padding()
        }
        
        .onAppear {
            loadClearedStages()
            stages = loadStages(from: category)

        }
    }
    
    func loadClearedStages() {
        let key = "clearedStages_\(category.rawValue)"
        if let saved = UserDefaults.standard.array(forKey: key) as? [Int] {
            clearedStages = Set(saved)
        }
    }
    
    func loadStages(from category: QuizCategory) -> [Stage] {
        let filename = "stages_\(category.rawValue)" // e.g., "stages_level_1"
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("ステージデータが見つかりません: \(filename).json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([Stage].self, from: data)
        } catch {
            print("ステージデータの読み込み失敗: \(error)")
            return []
        }
    }
    
    
}


// StageSelectView 本体の下に追加（ファイルはそのまま）
private struct StageButton: View {
    let stage: Stage
    let clearedStages: Set<Int>
    let onSelectStage: (Stage) -> Void

    var body: some View {
        let isUnlocked = clearedStages.contains(stage.id) || stage.id == (clearedStages.max() ?? 0) + 1

        Button(action: {
            if isUnlocked {
                onSelectStage(stage)
            }
        }) {
            Text("\(stage.id)")
                .frame(width: 60, height: 60)
                .background(isUnlocked ? Color.green : Color.secondary)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(!isUnlocked)
    }
}


#Preview {
    StageSelectView(
        category: .level_1,
        onSelectStage: { _ in },
        onBack: {}
    )
}
