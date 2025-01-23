//
//  CalendarView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 12/12/2024.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authState: AuthState
    
    @StateObject var viewModel: CalendarViewModel
    
    init(eventState: EventState, authUserId: String) {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(eventState: eventState, authUserId: authUserId))
    }
    
    var body: some View {
        NavigationStack {
            VStack() {
                HStack {
                    Text("Your next events:")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                    Spacer()
                }
                .padding()
                
                CustomCalendar(selectedDate: $viewModel.selectedDate, viewModel: viewModel)
                    .padding()
                
                VStack(alignment: .leading) {
                    if viewModel.eventsForSelectedDate.isEmpty {
                        Text("Your next events:")
                    } else {
                        Text("Events on \(viewModel.selectedDate.formatted(.dateTime.day().month(.twoDigits).year().locale(Locale(identifier: "pl")))):")
                    }
                    
                    ScrollView {
                        VStack(spacing: 5) {
                            if viewModel.eventsForSelectedDate.isEmpty {
                                ForEach(viewModel.futureEvents()) { event in
                                    NavigationLink(destination: SelectedEventView(event: event)
                                        .environmentObject(appState)
                                        .environmentObject(appState.eventState)) {
                                        CalendarListEventRow(event: event)
                                    }
                                }
                            } else {
                                ForEach(viewModel.eventsForSelectedDate) { event in
                                    NavigationLink(destination: SelectedEventView(event: event)
                                        .environmentObject(appState)
                                        .environmentObject(appState.eventState)) {
                                        CalendarListEventRow(event: event)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.horizontal)
                .padding(.horizontal)
                
                Spacer()
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar() {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SocialView(appState: appState, authState: authState)) {
                        Image(systemName: "person.2.fill")
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("MatchUp")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: MyProfileView(appState: appState, authState: authState)) {
                        Image(systemName: "person.circle")
                    }
                }
            }
            
            .navigationBarBackButtonHidden(true)
            .foregroundStyle(.white)
        }
        
        Spacer()
        
    }
}


struct CustomCalendar: View {
    @Binding var selectedDate: Date
    @State private var currentMonth: Date = Date()
    @ObservedObject var viewModel: CalendarViewModel
    
    let days = Calendar.current.shortWeekdaySymbols
    
    var body: some View {
        VStack {
            HStack {
                Text(currentMonth, format: .dateTime.month(.wide))
                    .font(.headline)
                
                Text(currentMonth, format: .dateTime.year())
                    .font(.headline)
                
                Button(action: {
                    print("Date selector")
                }) {
                    Image(systemName: "chevron.right")
                }
                
                Spacer()
                
                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                }) {
                    Image(systemName: "chevron.left")
                }
                
                .padding(.horizontal)
                
                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal, 10)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(5)
                }
                
                ForEach(viewModel.generateDays(for: currentMonth), id: \.self) { date in
                    Text(date == nil ? "" : "\(Calendar.current.component(.day, from: date!))")
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(
                            Group {
                                if date != nil && Calendar.current.isDate(date!, inSameDayAs: selectedDate) {
                                    Color.blue
                                }
                                if date != nil && viewModel.eventsForDay(date!).count > 0 { Color.blue.opacity(0.4) }
                                else {
                                    Color.clear
                                }
                            })
                        .cornerRadius(8)
                        .onTapGesture {
                            if let date = date {
                                selectedDate = date
                                viewModel.eventsForSelectedDate = viewModel.eventsForDay(date)
                            }
                        }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
    }
    
    private func generateDays(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        let paddingDays = calendar.component(.weekday, from: startOfMonth) - 1
        let totalDays = range.count + paddingDays
        
        return Array(0..<totalDays).map { index in
            if index < paddingDays {
                return nil
            } else {
                return calendar.date(byAdding: .day, value: index - paddingDays, to: startOfMonth)!
            }
        }
    }
}


struct CalendarListEventRow: View {
    let event: Event
    
    var body: some View {
        HStack {

            Text(event.date.formatted(.dateTime.day().month(.twoDigits).locale(Locale(identifier: "pl")) )
            )
                .frame(width: 60, alignment: .leading)
                .font(.system(size: 14, weight: .semibold))
            
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.system(size: 14, weight: .semibold))
                
                HStack {
                    Image(systemName: "clock")
                    Text(event.date, format: .dateTime.hour().minute())
                    Image(systemName: event.type.imageSymbol())
                    Text(event.type.description())
                }
                .font(.system(size: 14))
                .foregroundStyle(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(style: StrokeStyle(lineWidth: 1))
        )
    }
}


#Preview {
    let appState = AppState()
    CalendarView(eventState: EventState(), authUserId: user0.id).environmentObject(appState)
        .environmentObject(AuthState())
        .preferredColorScheme(.dark)
}
