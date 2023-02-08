//
//  LocalAuthenticationService.swift
//  FaceIDDemo
//
//  Created by Casey Hanley on 2/7/23.
//

import LocalAuthentication

struct LocalAuthenticationService {
    static func authenticate(
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (LocalAuthenticationError) -> Void
    ) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Gimme yer face"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                if success {
                    onSuccess()
                } else {
                    onFailure(.unableToAuthenticate)
                }
            }
        } else {
            onFailure(.biometricsNotConfigured)
        }
    }
}

enum LocalAuthenticationError: Error {
    case unableToAuthenticate
    case biometricsNotConfigured
}
