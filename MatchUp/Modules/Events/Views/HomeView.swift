//
//  HomeView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 28/11/2024.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedCity: String = "Your Location"
    @StateObject var viewModel: HomeViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authState: AuthState
    
    init(appState: AppState, eventState: EventState) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(appState: appState, eventState: eventState))
    }
    
    private let selectedIconColor: Color = .white
    
    var body: some View {
        VStack() {
            HStack {
                Text("In Your Area:")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                Spacer()
                
                Button(action: {
                    print("Location")
                }) {
                    Image(systemName: "location.fill")
                    Text(selectedCity)
                }
                .clipShape(Rectangle())
                .frame(width: 150, height: 30)
                .background(Color(red: 0.47, green: 0.47, blue: 0.50).opacity(0.24))
                .cornerRadius(40);
            }
            .padding()
            
            Button(action: {
                viewModel.refresh()
            }) {
                Image(systemName: "arrow.clockwise")
                Text("Refresh")
            }
            .foregroundStyle(Color.gray)
            
            // Event List Section
            if appState.isLoading {
                Spacer()
                ProgressView("Loading events...")
                Spacer()
            } else {
                
                ScrollView {
                    LazyVStack(spacing: 25) {
                        
                        ForEach(viewModel.events) { event in
                            NavigationLink(destination:
                                            SelectedEventView(event: event)
                                .environmentObject(appState)
                                .environmentObject(appState.eventState)) {
                                    EventRow(event: event)
                                }
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .backgroundStyle(.blue)
            }
                    
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
        .onDisappear {
            appState.eventState.locationService.stopUpdatingLocation()
        }
        
    }
}

#Preview {
    let appState = AppState()
    HomeView(appState: appState, eventState: EventState()).environmentObject(appState)
        .environmentObject(AuthState())
}
