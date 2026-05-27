//
//  AuthCoordinator.swift
//  frontend
//
//  Created by Alex Ly on 5/19/26.
//

import SwiftUI
import AppAuth
import WebKit
import KeychainSwift

@MainActor
class CognitoAuthManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var errorMessage = ""
    static let shared = CognitoAuthManager()
    private var configuration: OIDServiceConfiguration?
    private var authState: OIDAuthState?
    public var currentAuthFlow: OIDExternalUserAgentSession?
     
    func restoreSession() async{
        let keychain = KeychainSwift()
        if let expiryString = keychain.get("tokenExpiryTime"),
           let expiryTime = TimeInterval(expiryString),
           Date().timeIntervalSince1970 > expiryTime {

            await self.signOut()
            return
        }
        if keychain.get("accessToken") != nil {
            self.isSignedIn = true
        }
    }
    func discover() async {
        // discovers endpoints
        guard let forIssuer = URL(string: CognitoConfig.issuer) else {
            print("Error creating URL for : \(CognitoConfig.issuer)")
            return
        }
        let result: OIDServiceConfiguration? = await withCheckedContinuation { continuation in
            OIDAuthorizationService.discoverConfiguration(forIssuer: forIssuer) { configuration, error in
                guard let config = configuration else {
                    print("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: config)
            }
        }
        self.configuration = result
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
        let request = OIDAuthorizationRequest(
            configuration: configuration,
          clientId: CognitoConfig.clientID,
          scopes: [OIDScopeOpenID,OIDScopeProfile],
            redirectURL: redirectURI,
          responseType: OIDResponseTypeCode,
          additionalParameters: ["prompt": "login"])
        print("about to present auth")
        let result: OIDAuthState? = await withCheckedContinuation { continuation in
            print("inside continuation")
            self.currentAuthFlow = OIDAuthState.authState(
                byPresenting: request,
                presenting: presentingVC
            ) { authState, error in
                if let authState = authState {
                    let keychain = KeychainSwift()
                    print(authState.lastTokenResponse?.accessToken)
                    keychain.set(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN", forKey: "accessToken")
                    keychain.set(authState.lastTokenResponse?.refreshToken ?? "DEFAULT_TOKEN", forKey: "refreshToken")
                    keychain.set(authState.lastTokenResponse?.idToken ?? "DEFAULT_TOKEN", forKey: "idToken")
                    let expiryTime = Date().addingTimeInterval(3600 * 24 * 1) //1 day
                    keychain.set(String(expiryTime.timeIntervalSince1970), forKey: "tokenExpiryTime")
                } else {
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
        let keychain = KeychainSwift()
        keychain.delete("accessToken")
        keychain.delete("refreshToken")
        keychain.delete("idToken")
        keychain.delete("tokenExpiryTime")
        self.authState = nil
        self.isSignedIn = false
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
            URLQueryItem(name: "client_id", value: CognitoConfig.clientID),
            URLQueryItem(name: "logout_uri", value: CognitoConfig.logoutURL),
          ]
          if let logoutURL = components.url {
            UIApplication.shared.open(logoutURL, options: [:], completionHandler: nil)
          }
        }
    }
}

class SignInCoordinator: NSObject{
    var cognitoAuthManager: CognitoAuthManager = CognitoAuthManager.shared
    @objc func handleSignIn() {
        Task {
            guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = await windowScene.windows.first?.rootViewController else {
                            return
                    }
            await cognitoAuthManager.signIn(from: rootViewController)
        }
    }
}
class SignOutCoordinator: NSObject{
    var cognitoAuthManager: CognitoAuthManager = CognitoAuthManager.shared
    @objc func handleSignOut(){
        Task{
            await cognitoAuthManager.signOut()
        }
    }
}
