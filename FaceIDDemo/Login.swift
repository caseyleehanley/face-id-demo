//
//  Login.swift
//  FaceIDDemo
//
//  Created by Casey Hanley on 11/14/20.
//

import SwiftUI

struct Login: View {
    @EnvironmentObject var authenticated: Authenticated
    @State private var credentials = Credentials()
    
    private enum FormState {
        case idle
        case attemptingNormalSignIn
        case attemptingBiometricSignIn
        case success
        case failed
    }
    @State private var formState = FormState.idle
    
    var hasKeychainCredentials = false
    init() {
        let email = AppKeychain.getValue(for: "email")
        let password = AppKeychain.getValue(for: "password")
        hasKeychainCredentials = !email.isEmpty && !password.isEmpty
    }

    var body: some View {
        Form {
            TextField("Username", text: $credentials.email)
                .disabled(formState == .attemptingNormalSignIn || formState == .attemptingBiometricSignIn)
            SecureField("Password", text: $credentials.password)
                .disabled(formState == .attemptingNormalSignIn || formState == .attemptingBiometricSignIn)
            Button(action: {
                authenticateRemote()
            }) {
                if formState == .attemptingNormalSignIn {
                    ProgressView()
                } else {
                    Text("Sign In")
                }
            }
            .disabled(
                credentials.email.isEmpty
                || credentials.password.isEmpty
                || formState == .attemptingNormalSignIn
                || formState == .attemptingBiometricSignIn
            )
            
            if (hasKeychainCredentials) {
                Button(action: {
                    formState = .attemptingBiometricSignIn
                    LocalAuthenticationService.authenticate(
                        onSuccess: {
                            credentials.email = AppKeychain.getValue(for: "email")
                            credentials.password = AppKeychain.getValue(for: "password")
                            authenticateRemote()
                        }, onFailure: { error in
                            switch error {
                            case .unableToAuthenticate:
                                print("Unable to authenticate")
                            case .biometricsNotConfigured:
                                print("Biometrics not configured")
                            }
                        }
                    )
                }) {
                    if formState == .attemptingBiometricSignIn {
                        ProgressView()
                    } else {
                        HStack {
                            Image(systemName: "faceid")
                            Text("Sign In With Face ID")
                        }
                    }
                }
            }
        }
    }
    
    func authenticateRemote() {
        formState = .attemptingNormalSignIn
        Task {
            // attempt remote sign-in
            sleep(2)
            // await AuthService.login(username: credentials.email, password: credentials.password)
            // if !success { return }
            
            AppKeychain.updateValue(for: "email", with: credentials.email)
            AppKeychain.updateValue(for: "password", with: credentials.password)
            DispatchQueue.main.async {
                authenticated.remote = true
                
                // skip face id on first login
                authenticated.local = true
                formState = .success
            }
            
            // store tokens in keychain / userDefaults
            // keychain.updateValue(for: "idToken", with: tokenResponse.idToken)
            // keychain.updateValue(for: "accessToken", with: tokenResponse.accessToken)
            // keychain.updateValue(for: "refreshToken", with: tokenResponse.refreshToken)
        }
    }
}
