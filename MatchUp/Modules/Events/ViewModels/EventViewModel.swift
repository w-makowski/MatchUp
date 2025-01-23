//
//  EventViewModel.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 06/01/2025.
//

import Foundation

class EventViewModel: ObservableObject {
    var appState: AppState
    var eventState: EventState
    var authState: AuthState
    
    @Published var isUserInEvent: Bool = false
    @Published var event: Event
    @Published var showParticipantsSheet: Bool = false
    @Published var hasEventEnded: Bool = false
    
    init(event: Event, appState: AppState, eventState: EventState, authState: AuthState) {
        self.event = event
        self.appState = appState
        self.eventState = eventState
        self.authState = authState
        checkIfUserIsInEvent()
        markEventAsArchived()
    }
    
    func checkIfUserIsInEvent() {
        Task {
            do {
                let fetchedResponse = try await eventState.checkIfUserIsInEvent(user: authState.currentUser!, event: event)
                
                await MainActor.run {
                    isUserInEvent = fetchedResponse
                }
            }
        }
    }
    
    func joinEvent() {
        Task {
            do {
                try await eventState.joinUserToEvent(user: authState.currentUser!, event: event)
                await MainActor.run {
                    isUserInEvent = true
                }
            } catch {
                print("something went wrong while joining event: \(error)")
                await refreshEvent()
            }
        }
    }
    
    func leaveEvent() {
        Task {
            do {
                try await eventState.removeUserFromEvent(user: authState.currentUser!, event: event)
                await MainActor.run {
                    isUserInEvent = false
                }
            } catch {
                print("something went wrong while leaving event: \(error)")
                await refreshEvent()
            }
        }
    }
    
    func showParticipants() {
        showParticipantsSheet.toggle()
    }
    
    func getParticipants() -> [User] {
        return event.participants
    }
    
    func markEventAsArchived() {
        hasEventEnded = event.date < Date()
    }
    
    func getAuthUser() -> User {
        return authState.currentUser!
    }
    
    private func refreshEvent() async {
        do {
            let updatedEvent = try await eventState.fetchEvent(eventId: event.id)
            await MainActor.run {
                self.event = updatedEvent
            }
        } catch {
            print("Failed to refresh event: \(error)")
        }
    }
}
