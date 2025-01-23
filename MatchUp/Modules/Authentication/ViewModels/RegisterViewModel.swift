//
//  RegisterViewModel.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 28/11/2024.
//

import Foundation

class RegisterViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var name: String = ""
    @Published var surname: String = ""
    @Published var email: String = ""
    @Published var repeatPassword: String = ""
    
    @Published var errorMessage: String? = nil
    
    private let authState: AuthState
    private let appState: AppState
    
    init(authState: AuthState, appState: AppState) {
        self.authState = authState
        self.appState = appState
    }
    
    func signUp() {
        if (username.isEmpty || password.isEmpty) {
            errorMessage = "Username and password are required!"
        } else if password.count < 8 {
            errorMessage = "Password must be at least 8 characters long!"
        } else if (name.isEmpty || surname.isEmpty || email.isEmpty) {
            errorMessage = "Name, surname and email are required!"
        } else if (password != repeatPassword) {
            errorMessage = "Passwords do not match!"
        } else {
            print("Signing up...")
            errorMessage = nil
            
            Task {
                let result = await authState.register(username: username, name: name, surname: surname, email: email, password: password)
                
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
}
