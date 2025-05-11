//
//  Rank.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/06.
//

import Foundation

enum Kaikyu: String {
    case minarai = "見習い"
    case shugyochu = "修行中"
    case shodan = "初段"
    case nidan = "二段"
    case sandan = "三段"
    case yondan = "四段"
    case godan = "五段"
    case shihanDai = "師範代"
    case menkyoKaiden = "免許皆伝"
    case kami = "神"
    

    static func getKaikyu(for totalCorrect: Int) -> Kaikyu {
        switch totalCorrect {
        case 0..<30: return .minarai
        case 30..<100: return .shugyochu
        case 100..<500: return .shodan
        case 500..<1000: return .nidan
        case 1000..<1500: return .sandan
        case 1500..<2000: return .yondan
        case 2000..<3000: return .godan
        case 3000..<5000: return .shihanDai
        case 5000..<10000: return .menkyoKaiden
        default: return .kami
        }
    }
    
    
    static func nextThreshold(for totalCorrect: Int) -> Int? {
        switch totalCorrect {
        case 0..<30: return 30
        case 30..<100: return 100
        case 100..<500: return 500
        case 500..<1000: return 1000
        case 1000..<1500: return 1500
        case 1500..<2000: return 2000
        case 2000..<3000: return 3000
        case 3000..<5000: return 5000
        case 5000..<10000: return 10000
        default: return nil // 「神」ランクには次がない
        }
    }
    
    
}

