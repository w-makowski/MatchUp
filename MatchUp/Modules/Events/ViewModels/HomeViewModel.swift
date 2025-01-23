//
//  HomeViewModel.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 08/01/2025.
//

import Foundation

class HomeViewModel: ObservableObject {
    private var appState: AppState
    private var eventState: EventState
    
    @Published var events: [Event] = []
    
    init(appState: AppState, eventState: EventState) {
        self.appState = appState
        self.eventState = eventState
        self.eventState.locationService.startUpdatingLocation()
        refresh()
    }
    
    func refresh() {
        Task {
            await MainActor.run {
                appState.isLoading = true
            }
            do {
                try await eventState.fetchFutureEvents(distance: appState.defaultSearchDistance)
                await MainActor.run {
                    self.events = eventState.events
                }
            } catch {
                print("Error fetching events: \(error)")
            }
            await MainActor.run {
                appState.isLoading = false
            }
        }
    }
}
