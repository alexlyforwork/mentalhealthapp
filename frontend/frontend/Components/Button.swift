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

struct SignInButton: UIViewRepresentable{
    @EnvironmentObject var cognitoAuthManager: CognitoAuthManager
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton()
        button.setTitle("Sign in", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleSignIn), for: .touchUpInside)
        return button
    }
    func updateUIView(_ uiView: UIButton, context: Context) {
        context.coordinator.cognitoAuthManager = cognitoAuthManager
    }
    func makeCoordinator() -> SignInCoordinator {
        return SignInCoordinator()
    }
}

struct SignOutButton: UIViewRepresentable {
    @EnvironmentObject var cognitoAuthManager: CognitoAuthManager
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton()
        button.setTitle("Sign out", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleSignOut), for: .touchUpInside)
        return button
    }
    func updateUIView(_ uiView: UIButton, context: Context) {
        context.coordinator.cognitoAuthManager = cognitoAuthManager
    }
    
    func makeCoordinator() -> SignOutCoordinator {
        return SignOutCoordinator()
    }
}

