//
//  StartView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 05/01/2025.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authState: AuthState
    @State var isLoginView: Bool = true
    
    var body: some View {
        if authState.isAuthenticated {
            MainView()
                .environmentObject(appState)
                .environmentObject(authState)
        } else {
            if isLoginView {
                LoginView(authState: authState, appState: appState, isLoginView: $isLoginView)
                    .environmentObject(authState)
            } else {
                RegisterView(authState: authState, appState: appState)
            }
        }
    }
    
    
}

#Preview {
    let appState = AppState()
    let authState = AuthState()
    StartView()
        .environmentObject(appState)
        .environmentObject(authState)
        .preferredColorScheme(.dark)
        .foregroundStyle(.white)
}
