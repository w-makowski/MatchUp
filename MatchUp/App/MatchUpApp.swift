//
//  MatchUpApp.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 25/11/2024.
//

import SwiftUI
import Firebase

@main
struct MatchUpApp: App {
    @StateObject var authState = AuthState()
    @StateObject var appState = AppState()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .environmentObject(appState)
                .environmentObject(authState)
                .preferredColorScheme(.dark)
                .foregroundStyle(Color.white)
        }
    }
}
