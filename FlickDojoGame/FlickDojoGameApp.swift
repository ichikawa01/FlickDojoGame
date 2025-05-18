//
//  FlickDojoGameApp.swift
//  FlickDojoGame
//
//  Created by 市川涼 on 2025/05/10.
//

import SwiftUI
import FirebaseCore
import GoogleMobileAds
import AppTrackingTransparency



class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct FlickDojoGameApp: App {
        
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var soundSettings = SoundSettingsManager.shared

    
    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        requestTrackingPermission()
        }
    
    private func requestTrackingPermission() {
            if #available(iOS 14, *) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // 少し遅らせるのが安全
                    ATTrackingManager.requestTrackingAuthorization { status in
                        print("ATT status: \(status.rawValue)")
                    }
                }
            }
        }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(soundSettings)
        }
    }
}
