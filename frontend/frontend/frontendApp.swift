//
//  frontendApp.swift
//  frontend
//
//  Created by Alex Ly on 5/18/26.
//

import SwiftUI

@main
struct YourApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()

  var body: some Scene {
    WindowGroup {
        if authViewModel.isSignedIn {
            ContentView()
                .environmentObject(authViewModel)
        } else{
            AuthView.SignInView()
                .environmentObject(authViewModel)
        }
      }
    }
}
