//
//  AuthCoordinator.swift
//  frontend
//
//  Created by Alex Ly on 5/19/26.
//

import SwiftUI
import GoogleSignIn

class GoogleSignInCoordinator: NSObject{
    var authViewModel : AuthViewModel
    init(authViewModel: AuthViewModel){
        self.authViewModel = authViewModel
    }
    @objc func handleSignIn() {
        Task {
            guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = await windowScene.windows.first?.rootViewController else {
                            return
                    }
            authViewModel.signInWithGoogle(presenting: rootViewController)
        }
    }
}


class GoogleSignOutCoordinator: NSObject{
    var authViewModel : AuthViewModel
    init(authViewModel: AuthViewModel){
        self.authViewModel = authViewModel
    }
    @objc func handleSignOut(){
        authViewModel.signOutWithGoogle()
    }
}

