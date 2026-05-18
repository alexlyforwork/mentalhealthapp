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
        var body: some View {
        
            GoogleSignInButton()
                .frame(width: 240, height: 50)
        
        }
    }
    struct SignOutView: View {
        @EnvironmentObject var authViewModel: AuthViewModel
        var body: some View{
            GoogleSignOutButton()
                .frame(width: 240, height: 50)
        }
    }
        
}

#Preview {
    AuthView.SignInView()
}
