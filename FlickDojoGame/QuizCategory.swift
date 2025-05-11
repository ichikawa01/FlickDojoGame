//
//  QuizCategory.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/06.
//

import Foundation

enum QuizCategory: String, CaseIterable, Hashable {
    case level_1
    case level_2
    case level_3

    var title: String {
        switch self {
        case .level_1: return "初級"
        case .level_2: return "中級"
        case .level_3: return "上級"
        }
    }
}

