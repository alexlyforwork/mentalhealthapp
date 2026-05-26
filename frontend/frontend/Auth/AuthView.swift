//
//  AuthView.swift
//  frontend
//
//  Created by Alex Ly on 5/18/26.
//

import SwiftUI

enum AuthView{
    struct SignInView: View {
        @EnvironmentObject var cognitoAuthManager: CognitoAuthManager
        var body: some View{
            Text("Welcome to Mentalert")
                .foregroundColor(Color.blue)
            SignInButton()
                .modifier(AuthButton(width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height/10))
        }
    }
    struct SignOutView: View {
        @EnvironmentObject var cognitoAuthManager: CognitoAuthManager
        var body: some View{
            SignOutButton()
                .modifier(AuthButton(width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height/10))
        }
    }
        
}
