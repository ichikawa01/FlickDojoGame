//
//  Stage.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/12.
//

import Foundation

struct Stage: Identifiable, Codable {
    let id: Int
    let words: [WordItem]
    let category: QuizCategory
}
