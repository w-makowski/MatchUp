//
//  LoginViewModel.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 26/11/2024.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    
    @Published var errorMessage: String? = nil
    
    private let authState: AuthState
    private let appState: AppState
    
    init(authState: AuthState, appState: AppState) {
        self.authState = authState
        self.appState = appState
    }
    
    func signIn() {

        guard !username.isEmpty, !password.isEmpty else {
           errorMessage = "Please fill in all fields."
           return
        }

        errorMessage = nil
        
        Task {
            let result = await authState.login(username: username, password: password)
            
            switch result {
            case .success:
                await appState.loadDefaultPreferences(ueser: authState.currentUser!)
                await MainActor.run {
                    errorMessage = nil
                }
            case .failure(let error):
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
