//
//  SocialViewModel.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 17/12/2024.
//

import Foundation

class SocialViewModel: ObservableObject {
    private var appState: AppState
    private var authState: AuthState
    @Published var searchText: String = ""
    @Published var friends: [User] = []
    @Published var friendRequests: [User] = []
    private var allUsers: [User] = []
    @Published var suggestedUsers: [User] = []
    
    private var friendsIds: [String] = []
    private var sentInvitationsIds: [String] = []
    private var receivedInvitationsIds: [String] = []
    
    func searchUsers() {
        suggestedUsers = allUsers.filter {
            $0.username.lowercased().contains( searchText.lowercased() )
        }
    }
    
    init(appState: AppState, authState: AuthState){
        self.appState = appState
        self.authState = authState
        self.getAllUsers()
        self.prepareFriendsLists()
    }
    
    func getAllUsers() {
        Task {
            await getAllUsersAsync()
        }
    }
    
    private func getAllUsersAsync() async {
        do {
            self.allUsers = try await appState.userService.fetchAllUsers()
        } catch {
            print("Error getting all users: \(error)")
        }
    }
    
    func setCurrentTab(_ tab: Tab) {
        appState.currentTab = tab
    }
    
    func obtainUserLink() -> String {
        return "matchup://user/\(authState.currentUser?.username ?? "error")"
    }
    
    private func prepareFriendsLists() {
        Task {
            do {
                let friendsIds = try await appState.userService.fetchUserFriends(userId: authState.currentUser!.id)
                
                await MainActor.run {
                    self.friends = friendsIds["friends"] ?? []
                    self.friendRequests = friendsIds["requests"] ?? []
                }
            } catch {
                print("Error fetching friends ids: \(error)")
            }
        }
    }
    
    func removeFriend(_ user: User) {
        Task {
            do {
                try await appState.userService.removeFriend(myUserId: authState.currentUser!.id, otherUserId: user.id)
                
                await MainActor.run {
                    friends.removeAll { $0.id == user.id }
                }
            } catch {
                print("Error removing friend: \(error)")
            }
        }
    }
    
    func acceptRequest(_ user: User) {
        Task {
            do {
                try await appState.userService.addFriend(myUserId: authState.currentUser!.id, otherUserId: user.id)
                
                await MainActor.run {
                    friendRequests.removeAll { $0.id == user.id }
                    friends.append(user)
                }
            } catch {
                print("Error accepting friend request: \(error)")
            }
        }
    }
    
    func rejectRequest(_ user: User) {
        Task {
            do {
                try await appState.userService.removeFriend(myUserId: authState.currentUser!.id, otherUserId: user.id)
                
                await MainActor.run {
                    friendRequests.removeAll { $0.id == user.id }
                }
            } catch {
                print("Error rejecting friend request: \(error)")
            }
        }
    }
    
    func getUserSymbol() -> String {
        return authState.currentUser?.username.prefix(1).capitalized ?? ""
    }
    
    func getAuthUser() -> User {
        return authState.currentUser!
    }
}
