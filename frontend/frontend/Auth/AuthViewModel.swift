//
//  AuthViewModel.swift
//  frontend
//
//  Created by Alex Ly on 5/18/26.
//
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

class AuthViewModel: ObservableObject{
    @Published var isSignedIn = false
    @Published var errorMessage = ""
    func signInWithGoogle(presenting viewController: UIViewController){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
          guard error == nil else {
            // ...
            return
          }

          guard let user = result?.user,
                let idToken = user.idToken?.tokenString
          else {
            // ...
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in DispatchQueue.main.async{
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.isSignedIn = true
                    }
                }
            }
        }
    }
}
