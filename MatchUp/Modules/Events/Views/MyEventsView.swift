//
//  MyEventsView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 12/12/2024.
//

import SwiftUI

struct MyEventsView: View {
    @StateObject private var viewModel: MyEventsViewModel = MyEventsViewModel(eventState: nil, authState: nil)
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var eventState: EventState
    @EnvironmentObject var authState: AuthState
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button (action: {
                        viewModel.selectTab(.all)
                    }) {
                        Text("All")
                    }
                    .frame(width: 73)
                    .foregroundStyle(viewModel.selectedTab == .all ? .primary : .secondary)
                    .font(.system(size: 17, weight: viewModel.selectedTab == .all ? .semibold : .regular))
                    
                    Button (action: {
                        viewModel.selectTab(.created)
                    }) {
                        Text("Created")
                    }
                    .frame(width: 89)
                    .foregroundStyle(viewModel.selectedTab == .created ? .primary : .secondary)
                    .font(.system(size: 17, weight: viewModel.selectedTab == .created ? .semibold : .regular))
                    
                    Button (action: {
                        viewModel.selectTab(.joined)
                    }) {
                        Text("Joined")
                    }
                    .frame(width: 110)
                    .foregroundStyle(viewModel.selectedTab == .joined ? .primary : .secondary)
                    .font(.system(size: 17, weight: viewModel.selectedTab == .joined ? .semibold : .regular))
                }
                .padding(.top, 30)
                .padding(.bottom, 15)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading events...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else {
                    
                    ScrollView {
                        LazyVStack(spacing: 25) {
                            
                            ForEach(viewModel.events) { event in
                                NavigationLink(destination:
                                                SelectedEventView(event: event)
                                    .environmentObject(appState)
                                    .environmentObject(eventState)) {
                                        EventRow(event: event)
                                    }
                                    .buttonStyle(.plain)
                            }
                        }
                    }
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
        }
        .onAppear {
            if viewModel.authState == nil {
                viewModel.authState = authState
            }
            
            if viewModel.eventState == nil {
                viewModel.eventState = eventState
            }
        }
    }
}

#Preview {
    MyEventsView()
        .environmentObject(AppState())
        .environmentObject(AuthState())
        .environmentObject(EventState())
}
