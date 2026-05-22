//
//  AuthView.swift
//  frontend
//
//  Created by Alex Ly on 5/18/26.
//

import SwiftUI

enum AuthView{
    struct SignInView: View {
        @EnvironmentObject var authViewModel: AuthViewModel
        var body: some View{
            Text("Welcome to Mentalert")
                .foregroundColor(Color.blue)
//            GoogleSignInButton()
//                .modifier(AuthButton(width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height/10))
            SignInButton()
                .modifier(AuthButton(width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height/10))
//                .disabled(CognitoAuthManager.shared.isDiscovering)
        }
    }
    struct SignOutView: View {
        @EnvironmentObject var authViewModel: AuthViewModel
        var body: some View{
//            GoogleSignOutButton()
//                .modifier(AuthButton(width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height/10))
            SignOutButton()
                .modifier(AuthButton(width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height/10))
        }
    }
        
}
