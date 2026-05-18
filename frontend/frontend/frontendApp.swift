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
    @StateObject var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isSignedIn {
                    AuthView.SignOutView()
                        .environmentObject(authViewModel)
                } else {
                    AuthView.SignInView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }
}
