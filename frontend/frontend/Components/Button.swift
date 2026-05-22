//
//  Button.swift
//  frontend
//
//  Created by Alex Ly on 5/19/26.
//

import SwiftUI
import GoogleSignIn


struct AuthButton: ViewModifier {
    var width: CGFloat
    var height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .background(Color(hex: "#d8e2dc"))
            .cornerRadius(10)
    }
}

struct GoogleSignInButton: UIViewRepresentable{
    @EnvironmentObject var authViewModel: AuthViewModel
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton()
        button.setTitle("Sign in", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleSignIn), for: .touchUpInside)
        return button
    }
    func updateUIView(_ uiView: UIButton, context: Context) {
        context.coordinator.authViewModel = authViewModel
    }
    func makeCoordinator() -> GoogleSignInCoordinator {
        return GoogleSignInCoordinator(authViewModel: authViewModel)
    }
}

struct SignInButton: UIViewRepresentable{
    @EnvironmentObject var authViewModel: AuthViewModel
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton()
        button.setTitle("Sign in", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleSignIn), for: .touchUpInside)
        return button
    }
    func updateUIView(_ uiView: UIButton, context: Context) {
        context.coordinator.authViewModel = authViewModel
    }
    func makeCoordinator() -> SignInCoordinator {
        return SignInCoordinator(authViewModel: authViewModel)
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
    
    func makeCoordinator() -> GoogleSignOutCoordinator {
        return GoogleSignOutCoordinator(authViewModel: authViewModel)
    }
}

struct SignOutButton: UIViewRepresentable {
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
    
    func makeCoordinator() -> SignOutCoordinator {
        return SignOutCoordinator(authViewModel: authViewModel)
    }
}

