//
//  frontendApp.swift
//  frontend
//
//  Created by Alex Ly on 5/18/26.
//

import SwiftUI
import UIKit

@main
struct YourApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var cognitoAuthManager =  CognitoAuthManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if cognitoAuthManager.isSignedIn {
                    AuthView.SignOutView()
                        .environmentObject(cognitoAuthManager)
                } else {
                    AuthView.SignInView()
                        .environmentObject(cognitoAuthManager)
                }
            }
        }
    }
}
