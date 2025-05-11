//
//  QuizMode.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/06.
//

import Foundation

enum QuizMode: String, CaseIterable, Hashable {
    case lesson   // 全問解くまでの時間を測る
    case timeLimit    // 制限時間で何問解けるか

    var description: String {
        switch self {
        case .lesson: return "修行"
        case .timeLimit: return "時間制限"
        }
    }
}
