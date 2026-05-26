//
//  AppDelegate.swift
//  frontend
//
//  Created by Alex Ly on 5/18/26.
//

import UIKit
import FirebaseCore
//import GoogleSignIn
import AppAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    var  currentAuthFlow: OIDExternalUserAgentSession?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Task {
            await CognitoAuthManager.shared.discover()
            print("✅ Cognito discovered")
            CognitoAuthManager.shared.restoreSession()
        }
        return true
    }
    
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if let authFlow = CognitoAuthManager.shared.currentAuthFlow, authFlow.resumeExternalUserAgentFlow(with: url){
            currentAuthFlow = nil
            return true
        }
        return false
    }
}
