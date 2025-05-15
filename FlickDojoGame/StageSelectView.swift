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
    
    var latestUnlockedStage: Int {
        (clearedStages.max() ?? 0) + 1
    }


    var body: some View {
        
        ZStack{
            
            //背景
            Image(.gameback)
                .resizable()
                .ignoresSafeArea()
                .opacity(0.6)
            
            VStack{
                Spacer().frame(height: 10)
                HStack{
                    // 戻るボタン（左上）
                    Button(action: {
                        playSE(fileName: "1tap")
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
                Spacer().frame(height: 10)
                switch category {
                case .level_1:
                    Image(.woodLevel1)
                        .resizable()
                        .frame(width: 140, height: 60)
                case .level_2:
                    Image(.woodLevel2)
                        .resizable()
                        .frame(width: 140, height: 60)
                case .level_3:
                    Image(.woodLevel3)
                        .resizable()
                        .frame(width: 140, height: 60)
                }
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                        ForEach(stages, id: \.id) { stage in
                            StageButton(
                                stage: stage,
                                category: category,
                                clearedStages: clearedStages,
                                latestUnlockedStage: latestUnlockedStage,
                                onSelectStage: onSelectStage
                            )
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
    let category: QuizCategory
    let clearedStages: Set<Int>
    let latestUnlockedStage: Int
    let onSelectStage: (Stage) -> Void

    var body: some View {
        let isCleared = clearedStages.contains(stage.id)
        let isUnlocked = stage.id <= latestUnlockedStage
        let isLatest = stage.id == latestUnlockedStage && !isCleared

        Button(action: {
            if isUnlocked {
                playSE(fileName: "2tap")
                onSelectStage(stage)
            }
        }) {
            Text("\(stage.id)")
                .frame(width: 60, height: 60)
                .background(backgroundColor(for: isCleared, isLatest, isUnlocked))
                .foregroundColor(.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isUnlocked ? Color.clear : Color.gray, lineWidth: 1)
                )
        }
        .disabled(!isUnlocked)
    }

    func backgroundColor(for isCleared: Bool, _ isLatest: Bool, _ isUnlocked: Bool) -> Color {
        if isCleared {
            switch category {
            case .level_1: return .green
            case .level_2: return .yellow
            case .level_3: return .red
            }
        } else if isLatest {
            return .secondary
        } else {
            return .clear
        }
    }
}



#Preview {
    StageSelectView(
        category: .level_1,
        onSelectStage: { _ in },
        onBack: {}
    )
}
