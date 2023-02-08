//
//  Authenticated.swift
//  FaceIDDemo
//
//  Created by Casey Hanley on 11/14/20.
//

import Foundation

class Authenticated: ObservableObject {
    @Published var remote = false
    @Published var local = false
}
