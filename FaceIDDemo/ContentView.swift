//
//  ContentView.swift
//  FaceIDDemo
//
//  Created by Casey Hanley on 2/7/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var authenticated: Authenticated
        
    var body: some View {
        Group {
            if !authenticated.remote {
                Login()
            } else if !authenticated.local {
                Text("🙈").font(.largeTitle)
            } else {
                Text("🙉").font(.largeTitle)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            print(newPhase)
            if newPhase == .active {
                if !authenticated.remote { return }
                if authenticated.local { return }
                
                LocalAuthenticationService.authenticate(
                    onSuccess: {
                        DispatchQueue.main.async {
                            authenticated.local = true
                        }
                    }, onFailure: { error in
                        switch error {
                        case .unableToAuthenticate:
                            print("Unable to authenticate")
                        case .biometricsNotConfigured:
                            print("Biometrics not configured")
                        }
                        DispatchQueue.main.async {
                            authenticated.local = false
                        }
                    }
                )
            } else {
                authenticated.local = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
