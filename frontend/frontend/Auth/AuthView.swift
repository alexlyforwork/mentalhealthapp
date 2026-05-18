//
//  AuthView.swift
//  frontend
//
//  Created by Alex Ly on 5/18/26.
//

import SwiftUI

class AuthView{
    struct SignInView: View {
        var body: some View {
        
            GoogleSignInButton()
                .frame(width: 240, height: 50)
        
        }
    }
}

#Preview {
    AuthView.SignInView()
}
