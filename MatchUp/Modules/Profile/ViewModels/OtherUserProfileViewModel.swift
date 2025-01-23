//
//  OtherUserProfileViewModel.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 15/12/2024.
//

import Foundation

class OtherUserProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var invitationStatus: InvitationStatus = .notInvited
    private var appState: AppState
    private var authUser: User
    @Published var isOtherUserProfile: Bool = true
    
    init(user: User, appState: AppState, authUser: User) {
        self.user = user
        self.appState = appState
        self.authUser = authUser
        checkIfOtherUserProfile()
        checkInvitationStatus()
    }
    
    private func checkIfOtherUserProfile() {
        isOtherUserProfile = authUser.id != user.id
    }
    
    func handleInvitationButton() {
        if invitationStatus == .notInvited {
            sendInvitation()
        } else if invitationStatus == .accepted {
            removeFrriend()
        }
    }
    
    func sendInvitation() {
        Task {
            do {
                try await appState.userService.sendFriendInvitation(senderId: authUser.id, receiverId: user.id)
                await MainActor.run {
                    invitationStatus = .pending
                }
            } catch {
                print("Error sending invitation \(error)")
            }
        }
    }
    
    func removeFrriend() {
        Task {
            do {
                try await appState.userService.removeFriend(myUserId: authUser.id, otherUserId: user.id)
                await MainActor.run {
                    invitationStatus = .notInvited
                }
            } catch {
                print("Error sending invitation \(error)")
            }
        }
    }
    
    func checkInvitationStatus() {
        print("Checking invitation status for: \(user.username)")
        Task {
            do {
                guard let fetchedInvitationStatus = try await appState.userService.checkInvitationStatus(myUserId: authUser.id, otherUserId: user.id) else {
                    throw NSError(domain: "", code: 0, userInfo: nil)
                }
                await MainActor.run {
                    invitationStatus = fetchedInvitationStatus
                }
            } catch {
                print("Error fetching invitation status \(error)")
            }
        }
    }
    
    func selectInviteButtonImage() -> String {
        switch invitationStatus {
        case .notInvited: return "person.fill.badge.plus"
        case .pending: return "person.fill.questionmark"
        case .accepted: return "person.fill.xmark"

        }
    }
    
    func selectInviteButtonText() -> String {
        switch invitationStatus {
        case .notInvited: return "Invite"
        case .pending: return "Pending..."
        case .accepted: return "Remove from friends"
        }
    }
    
    func createFavouriteSportsText() -> String {
        if user.favouriteSports.isEmpty {
            return "No favourite sports"
        } else {
            return user.favouriteSports.joined(separator: ", ")
        }
    }
}

enum InvitationStatus {
    case notInvited
    case pending
    case accepted
}
