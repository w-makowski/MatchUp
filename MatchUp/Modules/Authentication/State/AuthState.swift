//
//  AuthState.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 28/11/2024.
//

import Foundation

class AuthState: ObservableObject {
    @Published var isAuthenticated: Bool = false //false
    @Published var currentUser: User? = nil
    
    var userService = UserService()
    
    func login(username: String, password: String) async -> Result<Void, Error> {
        await withCheckedContinuation { continuation in
            userService.login(username: username, password: password) { result in
                switch result {
                case .success(let user):
                    self.currentUser = user
                    self.isAuthenticated = true
                    continuation.resume(returning: .success(()))
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }
    
    func logout(){
        userService.logout() { result in
            switch result {
            case .success:
                self.isAuthenticated = false
                self.currentUser = nil
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func register(username: String, name: String, surname: String, email: String, password: String) async -> Result<Void, Error> {
        await withCheckedContinuation { continuation in
            userService.register(username: username, name: name, surname: surname, email: email, password: password) { result in
                switch result {
                case .success(let user):
                    self.currentUser = user
                    self.isAuthenticated = true
                    continuation.resume(returning: .success(()))
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }
}
