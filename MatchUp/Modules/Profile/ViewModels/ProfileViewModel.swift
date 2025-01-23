//
//  ProfileViewModel.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 15/12/2024.
//

import Foundation

class ProfileViewModel: ObservableObject {
    private var authState: AuthState
    private var appState: AppState
    
    @Published var name: String = ""
    @Published var surname: String = ""
    @Published var favouriteSports: [String] = []
    
    @Published var defaultSearchDistance: String = eventDistances[0]
    
    @Published var enableNotification: Bool = true {
            didSet {
                if !enableNotification {
                    previousNotifyStates = [notify24hBefore, notify12hBefore, notify6hBefore, notify3hBefore, notify1hBefore]
                    notify24hBefore = false
                    notify12hBefore = false
                    notify6hBefore = false
                    notify3hBefore = false
                    notify1hBefore = false
                } else if let previousStates = previousNotifyStates {
                    notify24hBefore = previousStates[0]
                    notify12hBefore = previousStates[1]
                    notify6hBefore = previousStates[2]
                    notify3hBefore = previousStates[3]
                    notify1hBefore = previousStates[4]
                    previousNotifyStates = nil
                }
            }
        }
    @Published var notify24hBefore: Bool = true
    @Published var notify12hBefore: Bool = false
    @Published var notify6hBefore: Bool = false
    @Published var notify3hBefore: Bool = false
    @Published var notify1hBefore: Bool = true
    private var previousNotifyStates: [Bool]?
    
    init(appState: AppState, authState: AuthState) {
        self.appState = appState
        self.authState = authState
        loadUserInfo()
    }
    
    func getUsername() -> String {
        return authState.currentUser?.username ?? ""
    }
    
    func getName() -> String {
        return authState.currentUser?.name ?? ""
    }
    
    func getSurname() -> String {
        return authState.currentUser?.surname ?? ""
    }
    
    func updateUserProfile() {
        if authState.isAuthenticated {
            authState.currentUser?.name = name
            authState.currentUser?.surname = surname
            authState.currentUser?.favouriteSports = favouriteSports
            appState.defaultSearchDistance = defaultSearchDistance
            appState.enableNotification = enableNotification
            appState.notify24hBefore = notify24hBefore
            appState.notify12hBefore = notify12hBefore
            appState.notify6hBefore = notify6hBefore
            appState.notify3hBefore = notify3hBefore
            appState.notify1hBefore = notify1hBefore
            let userData: [String: Any] = [
                "name": name,
                "surname": surname,
                "favourite_sports": favouriteSports,
                "default_search_distance": defaultSearchDistance,
                "enable_notification": enableNotification,
                "notify_24h_before": notify24hBefore,
                "notify_12h_before": notify12hBefore,
                "notify_6h_before": notify6hBefore,
                "notify_3h_before": notify3hBefore,
                "notify_1h_before": notify1hBefore
            ]
            appState.updateUserProfileInDB(userId: authState.currentUser!.id, userData: userData)
        }
    }
    
    func logout() {
        authState.logout()
    }
    
    func createFavouriteSportsText() -> String {
        if favouriteSports.isEmpty {
            return "No favourite sports"
        } else {
            return favouriteSports.joined(separator: ", ")
        }
    }
    
    private func loadUserInfo() {
        if authState.isAuthenticated {
            name = authState.currentUser?.name ?? ""
            surname = authState.currentUser?.surname ?? ""
            favouriteSports = authState.currentUser?.favouriteSports ?? []
            self.defaultSearchDistance = appState.defaultSearchDistance
            self.enableNotification = appState.enableNotification
            self.notify24hBefore = appState.notify24hBefore
            self.notify12hBefore = appState.notify12hBefore
            self.notify6hBefore = appState.notify6hBefore
            self.notify3hBefore = appState.notify3hBefore
            self.notify1hBefore = appState.notify1hBefore
        }
    }
}
