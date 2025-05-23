//
//  RankingManager.swift
//  MyMusic
//
//  Created by 市川涼 on 2025/05/08.
//

import Foundation
import FirebaseFirestore

enum QuizModeRank: String {
    case level_1
    case level_2
    case level_3
}

enum RankingPeriod: String, CaseIterable {
    case daily, weekly, monthly, total
    
    var displayName: String {
        switch self {
        case .daily: return "今日"
        case .weekly: return "今週"
        case .monthly: return "今月"
        case .total: return "累計"
        }
    }
}

class RankingManager {
    static let shared = RankingManager()
    private let db = Firestore.firestore()
    
    func submitScore(userId: String, userName: String, score: Int, mode: QuizModeRank) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        
        let periods: [RankingPeriod] = [.daily, .weekly, .monthly, .total]
        
        for period in periods {
            var suffix = ""
            let calendar = Calendar(identifier: .gregorian)
            let now = Date()
            
            switch period {
            case .daily:
                suffix = formatDate(now, format: "yyyyMMdd")
                
            case .weekly:
                // 今週の月曜日を取得して yyyyMMdd にする
                let weekday = calendar.component(.weekday, from: now)
                let offset = weekday == 1 ? -6 : 2 - weekday // 日曜なら-6、それ以外は月曜起点
                if let monday = calendar.date(byAdding: .day, value: offset, to: now) {
                    suffix = formatDate(monday, format: "yyyyMMdd")
                }
                
            case .monthly:
                suffix = formatDate(now, format: "yyyyMM")
                
            case .total:
                suffix = "total"
            }
            
            let topDoc = "\(mode.rawValue)_\(period.rawValue)"
            let dateKey = suffix // 例: 20250508
            
            let ref = db.collection("rankings")
                .document(topDoc)
                .collection(dateKey) // ← 日付ごとのサブコレクション
                .document(userId)
            
            
            // 過去の記録を超えているなら更新
            ref.getDocument { doc, _ in
                let previousScore = doc?.data()?["score"] as? Int ?? 0
                
                if score > previousScore {
                    let data: [String: Any] = [
                        "userId": userId,
                        "userName": userName,
                        "score": score,
                        "timestamp": Timestamp(date: now)
                    ]
                    
                    ref.setData(data, merge: true)
                }
            }
        }
    }
    
    
    
    private struct CachedRanking {
        let entries: [RankingEntry]
        let expireAt: Date
    }
    
    private var rankingCache: [String: CachedRanking] = [:]
    
    func fetchTopRankings(mode: QuizModeRank, period: RankingPeriod, completion: @escaping ([RankingEntry]) -> Void) {
        let topDoc = "\(mode.rawValue)_\(period.rawValue)"
        let now = Date()
        var dateKey = ""
        
        let utcCalendar = Calendar(identifier: .gregorian)
        var calendar = utcCalendar
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        switch period {
        case .daily:
            formatter.dateFormat = "yyyyMMdd"
            dateKey = formatter.string(from: now)
        case .weekly:
            let weekday = calendar.component(.weekday, from: now)
            let offset = weekday == 1 ? -6 : 2 - weekday
            if let monday = calendar.date(byAdding: .day, value: offset, to: now) {
                formatter.dateFormat = "yyyyMMdd"
                dateKey = formatter.string(from: monday)
            }
        case .monthly:
            formatter.dateFormat = "yyyyMM"
            dateKey = formatter.string(from: now)
        case .total:
            dateKey = "total"
        }
        
        let cacheKey = "\(mode.rawValue)_\(period.rawValue)_\(dateKey)"
        
        // ✅ キャッシュチェック
        if period != .daily, let cached = self.rankingCache[cacheKey], Date() < cached.expireAt {
            completion(cached.entries)
            return
        }
        
        let docRef = db.collection("rankings")
            .document(topDoc)
            .collection(dateKey)
            .document("top")
        
        docRef.getDocument { snapshot, error in
            
            guard let data = snapshot?.data(),
                  let topArray = data["top"] as? [[String: Any]] else {
                completion([])
                return
            }
            
            let entries = topArray.compactMap { dict -> RankingEntry? in
                guard let name = dict["userName"] as? String,
                      let score = dict["score"] as? Int,
                      let userId = dict["userId"] as? String else {
                    return nil
                }
                return RankingEntry(userId: userId, userName: name, score: score)
            }
            
            // ✅ daily 以外のみキャッシュに保存
            if period != .daily {
                var expireDate: Date?
                var components = calendar.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: now)
                components.hour = 0
                components.minute = 0
                components.second = 0
                components.nanosecond = 0
                components.day! += 1
                expireDate = calendar.date(from: components)
                
                if let expireAt = expireDate {
                    self.rankingCache[cacheKey] = CachedRanking(entries: entries, expireAt: expireAt)
                }
            }
            
            completion(entries)
        }
    }
    
    
    
    
    func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
}

