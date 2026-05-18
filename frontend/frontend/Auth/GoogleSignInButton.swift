//
//  GoogleSignInButton.swift
//  frontend
//
//  Created by Alex Ly on 5/18/26.
//

import SwiftUI
import GoogleSignIn

struct GoogleSignInButton: UIViewRepresentable{
    @EnvironmentObject var authViewModel: AuthViewModel
    func makeUIView(context: Context) -> GIDSignInButton {
        let button = GIDSignInButton()
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleSignIn), for: .touchUpInside)
        return button
    }
    func updateUIView(_ uiView: GIDSignInButton, context: Context) {
        context.coordinator.authViewModel = authViewModel
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator(authViewModel: authViewModel)
    }
    class Coordinator: NSObject{
        var authViewModel : AuthViewModel
        init(authViewModel: AuthViewModel){
            self.authViewModel = authViewModel
        }
        @objc func handleSignIn(){
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = windowScene.windows.first?.rootViewController else {
                            return
                        }
            authViewModel.signInWithGoogle(presenting: rootViewController)
        }
    }
}

struct GoogleSignOutButton: UIViewRepresentable {
    @EnvironmentObject var authViewModel: AuthViewModel
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton()
        button.setTitle("Sign out", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleSignOut), for: .touchUpInside)
        return button
    }
    func updateUIView(_ uiView: UIButton, context: Context) {
        context.coordinator.authViewModel = authViewModel
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(authViewModel: authViewModel)
    }
    class Coordinator: NSObject{
        var authViewModel : AuthViewModel
        init(authViewModel: AuthViewModel){
            self.authViewModel = authViewModel
        }
        @objc func handleSignOut(){
            authViewModel.signOutWithGoogle()
        }
    }
}
