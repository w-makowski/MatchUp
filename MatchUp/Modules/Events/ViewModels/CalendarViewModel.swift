//
//  CalendarViewModel.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 06/01/2025.
//

import Foundation

class CalendarViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedDate: Date = Date()
    @Published var eventsForSelectedDate: [Event] = []
    
    private var eventState: EventState
    private var authUserId: String
    
    
    init(eventState: EventState, authUserId: String) {
        self.eventState = eventState
        self.authUserId = authUserId
        self.fetchUserEvents()
    }
    
    private func fetchUserEvents() {
        Task {
            do {
                try await eventState.fetchUserEvents(userId: authUserId)
                await MainActor.run {
                    self.events = eventState.events
                }
            } catch {
                print ("Error fetching user events: \(error)")
            }
        }
    }
    
    func futureEvents() -> [Event] {
        return events.filter { $0.date >= Date() }.sorted { $0.date < $1.date }
    }
    
    func eventsForDay(_ date: Date) -> [Event] {
        events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }.sorted { $0.date < $1.date }
    }
    
    func generateDays(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        let paddingDays = calendar.component(.weekday, from: startOfMonth) - 1
        let totalDays = range.count + paddingDays
        
        let days = Array(0..<totalDays).map { index -> Date? in
            if index < paddingDays {
                return nil
            } else {
                return calendar.date(byAdding: .day, value: index - paddingDays, to: startOfMonth)!
            }
        }
        
        return days
    }
    
}
