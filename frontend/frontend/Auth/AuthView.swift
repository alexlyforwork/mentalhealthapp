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
            GoogleSignInButton()
                .modifier(AuthButton(width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height/10))
            
        }
    }
    struct SignOutView: View {
        @EnvironmentObject var authViewModel: AuthViewModel
        var body: some View{
            GoogleSignOutButton()
                .modifier(AuthButton(width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height/10))
        }
    }
        
}

#Preview {
    AuthView.SignInView()
}
