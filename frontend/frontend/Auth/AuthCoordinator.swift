//
//  AuthCoordinator.swift
//  frontend
//
//  Created by Alex Ly on 5/19/26.
//

import SwiftUI
import AppAuth
import WebKit

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

class SignInCoordinator: NSObject{
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
            await CognitoAuthManager.shared.signIn(from: rootViewController)
            // Sync Cognito's result back to the AuthViewModel that the UI observes
            await MainActor.run {
                authViewModel.isSignedIn = CognitoAuthManager.shared.isSignedIn
            }
        }
    }
}
class SignOutCoordinator: NSObject{
    var authViewModel : AuthViewModel
    init(authViewModel: AuthViewModel){
        self.authViewModel = authViewModel
    }
    @objc func handleSignOut(){
        Task{
            await CognitoAuthManager.shared.signOut()
            await MainActor.run {
                authViewModel.isSignedIn = false
            }
        }
    }
}

@MainActor
class CognitoAuthManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var errorMessage = ""
    @Published var isDiscovering = true
    static let shared = CognitoAuthManager()
    private var configuration: OIDServiceConfiguration?
    private var authState: OIDAuthState?
    public var currentAuthFlow: OIDExternalUserAgentSession?
    
    func discover() async {
        // discovers endpoints
        guard let forIssuer = URL(string: CognitoConfig.issuer) else {
            print("Error creating URL for : \(CognitoConfig.issuer)")
            isDiscovering = false
            return
        }
        let result: OIDServiceConfiguration? = await withCheckedContinuation { continuation in
            print("start discover")
            OIDAuthorizationService.discoverConfiguration(forIssuer: forIssuer) { configuration, error in
                guard let config = configuration else {
                    print("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                    continuation.resume(returning: nil)
                    return
                }
                print("end discover")
                continuation.resume(returning: config)
            }
        }
        self.configuration = result
        self.isDiscovering = false
    }
    func signIn(from presentingVC: UIViewController) async {
        // builds authentication request
        guard let redirectURI = URL(string: CognitoConfig.redirectURI) else {
            print("❌ signIn: invalid redirectURI — check CognitoConfig.redirectURI")
            return
        }

        guard let configuration = self.configuration else {
            print("❌ signIn: configuration still nil after discover() — check CognitoConfig.issuer and network")
            return
        }
//        await MainActor.run {
//            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
//                    print("Total cookies: \(cookies.count)")
//                    for cookie in cookies {
//                        print("Cookie: \(cookie.name) = \(cookie.value) | domain: \(cookie.domain)")
//                    }
//                }
//                WKWebsiteDataStore.default().removeData(
//                    ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
//                    modifiedSince: Date(timeIntervalSince1970: 0)
//                ) {
//                    print("cookies cleared")
//                }
//            }
        let request = OIDAuthorizationRequest(
            configuration: configuration,
          clientId: CognitoConfig.clientID,
          scopes: [OIDScopeOpenID,OIDScopeProfile],
            redirectURL: redirectURI,
          responseType: OIDResponseTypeCode,
          additionalParameters: nil)
        print("about to present auth")
        let result: OIDAuthState? = await withCheckedContinuation { continuation in
            print("inside continuation")
            self.currentAuthFlow = OIDAuthState.authState(
                byPresenting: request,
                presenting: presentingVC
            ) { authState, error in
                print("callback fired")
                print(authState)
                if let authState = authState {
                    print("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
                } else {
                    print(error)
                    print("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                }
                continuation.resume(returning: authState)
            }
        }
        self.authState = result
        self.isSignedIn = result != nil
    }
    func fetchUserInfo() async {
        guard let authState = self.authState else {return }
        guard
          let userinfoEndpoint = authState.lastAuthorizationResponse.request.configuration
            .discoveryDocument?.userinfoEndpoint
        else {
          print("Userinfo endpoint not declared in discovery document")
          return
        }

        let _currentAccessToken: String? = authState.lastTokenResponse?.accessToken

        authState.performAction { (accessToken, idToken, error) in
            guard let accessToken = accessToken else {return }
          var urlRequest = URLRequest(url: userinfoEndpoint)
          urlRequest.allHTTPHeaderFields = ["Authorization": "Bearer \(accessToken)"]
          let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // ...
            var json: [AnyHashable: Any]?
              guard let data = data else {return }
            do {
              json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
              print("JSON Serialization Error")
            }
            // ...
            if let json = json {
              print("Success: \(json)")
            }
          }
        }
    }
    func signOut() async {
        guard let authState = authState else {return }
        guard
          let endSessionEndpoint = authState.lastAuthorizationResponse.request.configuration
            .discoveryDocument?.endSessionEndpoint
        else {
          print("EndSession endpoint not declared in discovery document")
          return
        }
        if let endSession = URL(string: endSessionEndpoint.absoluteString) {
          // Prepare the logout URL with the ID token hint and redirect URI
          var components = URLComponents(url: endSessionEndpoint, resolvingAgainstBaseURL: false)!
          components.queryItems = [
            URLQueryItem(name: "client_id", value: CognitoConfig.clientID),  // Your client ID
            URLQueryItem(name: "logout_uri", value: CognitoConfig.logoutURL),  // Your app's redirect URI
          ]

          if let logoutURL = components.url {
            UIApplication.shared.open(logoutURL, options: [:], completionHandler: nil)
            self.isSignedIn = false
          }
        }
        
    }
}

