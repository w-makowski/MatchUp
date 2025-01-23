//
//  MyEventsViewModel.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 14/12/2024.
//

import Foundation

class MyEventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var allEvents: [Event] = []
    @Published var selectedTab: MyEventsTab = .all
    @Published var isLoading: Bool = false
    
    var authState: AuthState?
    
    var eventState: EventState? {
        didSet {
            fetchUserEvents()
        }
    }
    
    init(eventState: EventState?, authState: AuthState?) {
        self.eventState = eventState
        self.authState = authState
    }
    
    func selectTab(_ tab: MyEventsTab) {
        selectedTab = tab
        filterEvents(by: selectedTab)
    }
    
    func updateEvents() {
        guard let eventState = eventState else { return }
        events = eventState.filterEvents(by: selectedTab)
    }
    
    func fetchUserEvents() {
        Task {
            await MainActor.run {
                isLoading = true
            }
            do {
                try await eventState!.fetchUserEvents(user: authState!.currentUser!)
                await MainActor.run {
                    self.allEvents = eventState!.events
                    self.events = allEvents
                    filterEvents(by: selectedTab)
                }
            } catch {
                print ("Error fetching user events: \(error)")
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    func filterEvents(by type: MyEventsTab) {
        switch type {
        case .all:
            events = allEvents
        case .created:
            events = allEvents.filter { $0.creator == authState!.currentUser }
        case .joined:
            events = allEvents.filter { $0.participants.contains(authState!.currentUser!) }
        }
    }
}
