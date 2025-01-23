//
//  EventState.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 05/12/2024.
//

import Foundation

class EventState: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedEvent: Event?
    var locationService: LocationService = LocationService()
    private var eventService = EventService()
    
    func fetchEvents() async throws {
        self.events = try await eventService.fetchAllEvents()
    }
    
    func fetchFutureEvents() async throws {
        self.events = try await eventService.fetchFutureEvents()
    }
    
    func fetchFutureEvents(distance: String) async throws {

        let futureEvents = try await eventService.fetchFutureEvents()
        
        if distance == eventDistances[0] {
            
            guard let currentLocation = locationService.currentLocation else {
                print("Unable to determine user's location.")
                self.events = []
                return
            }
            
            guard let currentCity = await locationService.getCityFromLocation(currentLocation.coordinate) else {
                print("Unable to determine user's city.")
                self.events = []
                return
            }
            
//            let filteredEvents = await withTaskGroup(of: Event?.self) { group -> [Event] in
//                for event in futureEvents {
//                    group.addTask {
//                        print("Rozpoczęto przetwarzanie eventu: \(event)")
//                        if let eventCity = await self.locationService.getCityFromLocation(event.location) {
//                            print("Pobrano miasto dla eventu: \(event). Miasto: \(eventCity).")
//                            return eventCity == currentCity ? event : nil
//                        } else {
//                            print("Nie można pobrać miasta dla eventu: \(event).")
//                            return nil
//                        }
//                        
//                        
//                    }
//                }
//                var results: [Event] = []
//                for await result in group {
//                    if let event = result {
//                        results.append(event)
//                        print("Dodano event: \(event) do wyników.")
//                    } else {
//                        print("Pominięto event.")
//                    }
//                }
//                print("Wyniki: \(results)")
//                return results
//            }
            var filteredEvents: [Event] = []

                var taskResults: [Event?] = []

                for event in futureEvents {
                    async let result = self.processEvent(event: event, currentCity: currentCity)
                    await taskResults.append(result)
                }

                for result in taskResults {
                    if let event = result {
                        filteredEvents.append(event)
                    }
                }
            await MainActor.run {
                self.events = filteredEvents
            }
            
        } else {
            await MainActor.run {
                self.events = futureEvents
            }
            try await filterEventsAsync(distance: convertDistancesToKm(distance))
        }
    }
        
    private func filterEventsAsync(distance: Double) async throws {
        let filteredEvents = await withTaskGroup(of: Event?.self) { group in
            for event in self.events {
                group.addTask {
                    let eventLocation = event.location.toCLLocation()
                    let distanceToEvent = self.locationService.calculateDistance(from: eventLocation) ?? 0
                    return distanceToEvent <= distance ? event : nil
                }
            }
            var results: [Event] = []
            for await result in group {
                if let event = result {
                    results.append(event)
                }
            }
            return results
        }
        await MainActor.run {
            self.events = filteredEvents
        }
        
    }
    
    func fetchUserEvents(user: User) async throws {
        let fetchedEvents = try await eventService.fetchUserEvents(userId: user.id)
        await MainActor.run {
            self.events = fetchedEvents
        }
    }
    
    func fetchUserEvents(userId: String) async throws {
        let fetchedEvents = try await eventService.fetchUserEvents(userId: userId)
        await MainActor.run {
            self.events = fetchedEvents
        }
    }
    
    func selectEvent(_ event: Event) {
        self.selectedEvent = event
    }
    
    func clearSelection() {
        self.selectedEvent = nil
    }
    
    private func processEvent(event: Event, currentCity: String) async -> Event? {
        print("Rozpoczęto przetwarzanie eventu: \(event)")

        if let eventCity = await self.locationService.getCityFromLocation(event.location), eventCity == currentCity {
            print("Pobrano miasto dla eventu: \(event). Miasto: \(eventCity).")
            return event
        } else {
            print("Nie można pobrać miasta dla eventu: \(event).")
            return nil
        }
    }
    
    func filterEvents(by type: MyEventsTab) -> [Event] {
        switch type {
        case .all:
            return events
        case .created:
            return events
        case .joined:
            return events
        }
    }
    
    func filterEvents(by query: String, filters: [String: Any]) -> [Event] {
        events.filter { event in
            event.title.localizedStandardContains(query)
        }
    }
    
    func uploadEvent(_ event: Event) async throws {
        do {
            let docRef = try await eventService.addEvent(event)
            
            await MainActor.run {
                event.id = docRef.documentID
            }
        } catch {
            throw NSError(domain: "EventService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to upload event: \(error.localizedDescription)"])
        }
    }
    
    func joinUserToEvent(user: User, event: Event) async throws {
        
        try await eventService.addUserToEvent(userId: user.id, eventId: event.id)
            
        await MainActor.run {
            event.takenSlots += 1
            event.participants.append(user)
        }
    }
    
    func fetchEvent(eventId: String) async throws -> Event {
        return try await eventService.fetchEvent(eventId: eventId)
    }
    
    func checkIfUserIsInEvent(user: User, event: Event) async throws -> Bool {
        return try await eventService.checkIfUserIsInEvent(userId: user.id, eventId: event.id)
    }
    
    func removeUserFromEvent(user: User, event: Event) async throws {
        
        try await eventService.removeUserFromEvent(userId: user.id, eventId: event.id)
        
        await MainActor.run {
            event.participants.removeAll { $0 == user }
            event.takenSlots -= 1
            print(event)
        }
    }
    
    func convertDistancesToKm( _ distance: String) -> Double {
        switch distance {
        case "300m": return 0.3
        case "500m": return 0.5
        case "1km": return 1
        case "2km": return 2
        case "5km": return 5
        case "10km": return 10
        case "15km": return 15
        case "20km": return 20
        case "30km": return 30
        case "50km": return 50
        case "100km": return 100
        case "150km": return 150
        case "200km": return 200
        default: return 10
        }
    }
}
