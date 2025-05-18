//
//  PurchaseManager.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/18.
//

import Foundation
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isAdRemoved: Bool = UserDefaults.standard.bool(forKey: "isAdRemoved")

    private init() {}

    func markAdAsRemoved() {
        isAdRemoved = true
        UserDefaults.standard.set(true, forKey: "isAdRemoved")
    }

    func purchaseRemoveAds() async {
        do {
            print("📦 商品読み込み開始")
            let products = try await Product.products(for: ["remove_ads"])
            guard let product = products.first else {
                print("❌ 商品が見つかりません")
                return
            }
            
            print("🛒 商品取得成功: \(product.displayName)")
            
            let result = try await product.purchase()
            
            _ = Transaction.updates.makeAsyncIterator()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(_):
                    print("✅ 購入成功 & 検証済")
                    PurchaseManager.shared.markAdAsRemoved()
                case .unverified:
                    print("⚠️ 購入は成功したが検証失敗")
                }
            case .userCancelled:
                print("🛑 ユーザーがキャンセル")
            default:
                print("❓ その他の結果: \(result)")
            }
            
        } catch {
            print("❌ 購入エラー: \(error)")
        }
    }
    
    func observeTransactionUpdates() {
        Task.detached {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    if transaction.productID == "remove_ads" {
                        await MainActor.run {
                            PurchaseManager.shared.markAdAsRemoved()
                        }
                        await transaction.finish()
                    }
                case .unverified:
                    break
                }
            }
        }
    }



    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            switch result {
                case .verified(let transaction):
                    if transaction.productID == "remove_ads" {
                        PurchaseManager.shared.markAdAsRemoved()
                    }
                case .unverified:
                    // 署名検証に失敗した場合
                    break
                }
        }
    }
}
