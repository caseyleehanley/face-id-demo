//
//  FaceIDDemoApp.swift
//  FaceIDDemo
//
//  Created by Casey Hanley on 2/7/23.
//

import SwiftUI

@main
struct FaceIDDemoApp: App {
    var authenticated = Authenticated()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authenticated)
        }
    }
}
