//
//  WordLoader.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/06.
//

import Foundation

struct WordItem: Codable, Hashable {
    let kanji: String
    let reading: String
}

func loadWords(from category: QuizCategory) -> [WordItem] {
    guard let url = Bundle.main.url(forResource: category.rawValue, withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let words = try? JSONDecoder().decode([WordItem].self, from: data) else {
        print("読み込み失敗: \(category.rawValue).json")
        return []
    }
    return words
}

