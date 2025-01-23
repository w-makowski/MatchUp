//
//  AppState.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 03/12/2024.
//

import Foundation

class AppState: ObservableObject {
    @Published var currentTab: Tab = .home
    @Published var isLoginView: Bool = true
    @Published var isOnline: Bool = true
    @Published var isLoading: Bool = false
    @Published var selectedUser: User? = nil
    var eventState = EventState()
    var userService = UserService()
    
    // Preferences
    @Published var defaultSearchDistance: String = eventDistances[0]
    @Published var enableNotification: Bool = true
    @Published var notify24hBefore: Bool = true
    @Published var notify12hBefore: Bool = false
    @Published var notify6hBefore: Bool = false
    @Published var notify3hBefore: Bool = false
    @Published var notify1hBefore: Bool = true
    
    func loadDefaultPreferences(ueser: User) async {
        
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let preferences = try await userService.fetchUserPreferences(userId: ueser.id)
            
            await MainActor.run {
                self.currentTab = .home
                self.defaultSearchDistance = preferences["default_search_distance"] as! String
                self.enableNotification = preferences["enable_notification"] as! Bool
                self.notify24hBefore = preferences["notify_24h_before"] as! Bool
                self.notify12hBefore = preferences["notify_12h_before"] as! Bool
                self.notify6hBefore = preferences["notify_6h_before"] as! Bool
                self.notify3hBefore = preferences["notify_3h_before"] as! Bool
                self.notify1hBefore = preferences["notify_1h_before"] as! Bool
                self.isLoading = false
                print("Loaded preferences")
            }
        } catch {
            print("Error fetching preferences")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    func updateUserProfileInDB(userId: String, userData: [String: Any]) {
        Task {
            do {
                try await userService.updateUserProfileInDB(userId: userId, userNewData: userData)
            } catch {
                print("Error updating user profile in db: \(error)")
            }
        }
    }
    
}

enum Tab {
    case home,
         search,
         create,
         myEvents,
         calendar
}
