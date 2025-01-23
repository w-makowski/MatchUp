//
//  SearchViewModel.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 06/01/2025.
//

import Foundation
import MapKit

class SearchViewModel: ObservableObject {
    private var appState: AppState
    private var eventState: EventState
    
    // for SearchView
    @Published var searchText: String = ""
    private var allEvents: [Event] = []
    @Published var events: [Event] = []
    @Published var suggestedEvents: [Event] = []
    @Published var showFilters: Bool = false
    //@Published var isLoading: Bool = false
    
    // for FilterView
    @Published var location: String = ""
    @Published var searchResults: [MKMapItem] = []
    @Published var isSearching: Bool = false
    @Published var distance: String? = nil
    @Published var date: Date? = nil
    @Published var time: Date? = nil
    @Published var category: EventType? = nil
    @Published var skillLevel: SkillLevel? = nil
    @Published var minNumberOfPlayers: String = ""
    @Published var maxNumberOfPlayers: String = ""
    @Published var showOnlyEventsICanJoin: Bool = false
    @Published var errorMessage: String? = nil
    
    init(appState: AppState, eventState: EventState) {
        self.appState = appState
        self.eventState = eventState
        refresh()
    }
    
    func searchEvents() {
        suggestedEvents = allEvents.filter {
            $0.title.lowercased().contains( searchText.lowercased() )
        }
    }
    
    func resesetFilters() {
        location = ""
        distance = nil
        date = nil
        time = nil
        category = nil
        skillLevel = nil
        minNumberOfPlayers = ""
        maxNumberOfPlayers = ""
        showOnlyEventsICanJoin = false
        errorMessage = nil
        refresh()
    }
    
    private func loadData() async {
        await MainActor.run {
            appState.isLoading = true
        }
        do {
            try await eventState.fetchFutureEvents()
            await MainActor.run {
                self.events = eventState.events
                self.allEvents = eventState.events
            }
        } catch {
            print("Error fetching events: \(error)")
        }
        await MainActor.run {
            appState.isLoading = false
        }
    }
    
    func refresh() {
        Task {
            await loadData()
        }
    }
    
    func filter() {
        Task {
            await filterAsync()
        }
    }
    
    @MainActor
    private func filterAsync() async {
        
        await loadData()
    
        if !minNumberOfPlayers.isEmpty && !minNumberOfPlayers.isInt {
            errorMessage = "Minimum number of players must be an integer."
            return
        }
        
        if !maxNumberOfPlayers.isEmpty && !maxNumberOfPlayers.isInt {
            errorMessage = "Maximum number of players must be an integer."
            return
        }
        
        errorMessage = nil
        
        if !location.isEmpty {
            events = events.filter { event in
                return event.searchAddress.localizedCaseInsensitiveContains(location)
            }
        }
        
        if let distance = distance {
            if distance == "Current City" {
                guard let currentLocation = eventState.locationService.currentLocation else {
                    print("Current location is unavailable.")
                    return
                }
                
                let userCity = await eventState.locationService.getCityFromLocation(currentLocation.coordinate)
                
                events = await withTaskGroup(of: Event?.self) { group in
                    for event in events {
                        group.addTask {
                            guard let eventCity = await self.eventState.locationService.getCityFromLocation(event.location) else {
                                return nil
                            }
                            return eventCity == userCity ? event : nil
                        }
                    }
                    
                    var filteredEvents: [Event] = []
                    for await event in group {
                        if let event = event {
                            filteredEvents.append(event)
                        }
                    }
                    return filteredEvents
                }
                
            } else {
                let maxDistanceInKm = eventState.convertDistancesToKm(distance)
                
                events = events.filter { event in
                    let eventLocation = CLLocation(latitude: event.location.latitude, longitude: event.location.longitude)
                    if let distanceFromUser = eventState.locationService.calculateDistance(from: eventLocation) {
                        return distanceFromUser <= maxDistanceInKm
                    }
                    return false
                }
            }
        }
        
        if let date = date {
            events = events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
        }
        
        if let time = time {
            let calendar = Calendar.current
            events = events.filter { event in
                let eventTime = calendar.dateComponents([.hour, .minute], from: event.date)
                let filterTime = calendar.dateComponents([.hour, .minute], from: time)
                return eventTime.hour == filterTime.hour && eventTime.minute == filterTime.minute
            }
        }
        
        if let category = category {
            events = events.filter { $0.type == category }
        }
        
        if let skillLevel = skillLevel {
            events = events.filter { $0.skillLevel == skillLevel }
        }
        
        if let minPlayers = Int(minNumberOfPlayers) {
            events = events.filter { $0.totalSlots >= minPlayers }
        }
        
        if let maxPlayers = Int(maxNumberOfPlayers) {
            events = events.filter { $0.totalSlots <= maxPlayers }
        }
        
        if showOnlyEventsICanJoin {
            events = events.filter { $0.takenSlots < $0.totalSlots }
        }
    }
    
    func searchForPlaces(query: String, competion: @escaping ([MKMapItem]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let polandCenter = CLLocationCoordinate2D(latitude: 52.0, longitude: 19.0)
        let regionSpan = MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0)
        request.region = MKCoordinateRegion(center: polandCenter, span: regionSpan)
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let response = response else {
                print("Error searching for places: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let filteredResults = response.mapItems.filter { item in
                let placemark = item.placemark
                return placemark.countryCode == "PL" && (placemark.locality != nil || placemark.administrativeArea != nil || placemark.subLocality != nil) && (item.name == placemark.locality || item.name == placemark.administrativeArea || item.name == placemark.subLocality)
            }
            competion(filteredResults)
        }
    }
    
    func performActionOnChange() {
        if !location.isEmpty {
            searchForPlaces(query: location) { items in
                self.searchResults = items
            }
        } else {
            searchResults = []
        }
    }
    
    func handleSelectSearchLocation(item: MKMapItem) {
        location = formatAddress(from: item)
        isSearching = false
    }
    
    func formatAddress(from item: MKMapItem) -> String {
        let placemark = item.placemark
        let components = [
            item.name,
            placemark.subLocality,
            placemark.locality,
            placemark.administrativeArea,
        ]
        
        let nonOptionalComponents = components.compactMap { $0 }
        
        let normalizedLocation = removeDuplicatesAndNormalize(location: nonOptionalComponents.joined(separator: ", "), components: nonOptionalComponents)
        return normalizedLocation
    }
    
    private func removeDuplicatesAndNormalize(location: String, components: [String]) -> String {
        //let components = location.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let uniqueComponents = Array(Set(components)).sorted {
            let range1 = location.range(of: $0)!
            let range2 = location.range(of: $1)!
            return range1.lowerBound < range2.lowerBound
        }
        return uniqueComponents.joined(separator: ", ")
    }
}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}
