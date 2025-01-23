//
//  CreateEventModel.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 12/12/2024.
//

import Foundation
import CoreLocation

class CreateEventModel: ObservableObject {
    private var eventState: EventState
    private var appState: AppState
    private var authState: AuthState
    
    @Published var isEventCreated: Bool = false
    @Published var createdEvent: Event? = nil
    
    @Published var eventName: String = ""
    @Published var category: EventType? = nil
    @Published var location: CLLocationCoordinate2D? = nil
    @Published var address: String = ""
    @Published var date: Date = Date()
    @Published var time: Date = Date()
    @Published var numberOfPlayers: Int? = nil
    @Published var skillLevel: SkillLevel? = nil
    @Published var description: String = ""
    @Published var errorMessage: String? = nil
    private var fullAddress: String = ""
    
    let calendar = Calendar.current
    
    init(appState: AppState, authState: AuthState) {
        self.appState = appState
        self.eventState = appState.eventState
        self.authState = authState
    }
    
    func reset() {
        eventName = ""
        location = nil
        address = ""
        date = Date()
        time = Date()
        category = nil
        skillLevel = nil
        numberOfPlayers = nil
        description = ""
        errorMessage = nil
        isEventCreated = false
        createdEvent = nil
        fullAddress = ""
    }
    
    private func combine(date: Date, time: Date) -> Date {
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second
        
        if let combinedDate = calendar.date(from: combinedComponents) {
            return combinedDate
        } else {
            return date
        }
        
    }
    
    func createEvent() async {
        if let validationError = validateEvent() {

            await MainActor.run {
                errorMessage = validationError
            }
            return
        }
        
        let generatedFullAddress = await createFullAddress()
        
        await MainActor.run {
            fullAddress = generatedFullAddress
            createdEvent = Event(title: eventName, creator: authState.currentUser!, type: category!, location: location!, address: address, searchAddress: fullAddress, date: combine(date: date, time: time), totalSlots: numberOfPlayers!, takenSlots: 0, skillLevel: skillLevel!, description: description)
        }
        
        do {
            try await eventState.uploadEvent(createdEvent!)
            await MainActor.run {
               isEventCreated = true
           }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to create event: \(error.localizedDescription)"
            }

        }
    }
    
    func reverseGeocode(location: CLLocationCoordinate2D) {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        eventState.locationService.reverseGeocode(location: clLocation) { address in
            self.address = address ?? "Unknown Address"
        }
    }
    
    private func createFullAddress() async -> String {
        await withCheckedContinuation { continuation in
            let clLocation = CLLocation(latitude: location!.latitude, longitude: location!.longitude)
            eventState.locationService.reverseGeocodeFullAddress(location: clLocation) { address in
                continuation.resume(returning: address ?? "Unknown Address")
            }
        }
    }
    
    private func validateEvent() -> String? {

        if eventName.isEmpty {
            return "Please provide event name"
        }
    
        if category == nil {
            return "Please select event category"
        }
        
        if location == nil {
            return "Please provide event location"
        }
        
        if numberOfPlayers == nil {
            return "Please provide number of players"
        }
        
        if skillLevel == nil {
            return "Please select event skill level"
        }
        
        return nil
    }
    
}
