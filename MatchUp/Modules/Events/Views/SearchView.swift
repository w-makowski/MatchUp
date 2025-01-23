//
//  SearchView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 01/12/2024.
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authState: AuthState
    @EnvironmentObject var eventState: EventState
    
    init(appState: AppState, eventState: EventState) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(appState: appState, eventState: eventState))
    }
    
    private let selectedIconColor: Color = .white
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack() {
                    
                    ZStack {
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.showFilters.toggle()
                            }) {
                                Label("Filters", systemImage: "slider.horizontal.3")
                            }
                            .sheet(isPresented: $viewModel.showFilters) {
                                FiltersView(viewModel: viewModel)
                            }
                            .padding(.trailing, 15)
                        }
                        
                        Button(action: {
                            viewModel.refresh()
                        }) {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh")
                        }
                        .foregroundStyle(Color.gray)
                        Spacer()
                        
                    }
                    
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
                                        .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(maxHeight: .infinity)
                        .backgroundStyle(.blue)
                    }
                }
                .onAppear {
                    viewModel.searchText = ""
                    print(viewModel.events)
                }
                .searchable(
                    text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search Events"
                )
                .searchSuggestions {
                    ForEach(viewModel.suggestedEvents) { event in
                        NavigationLink(destination:
                                        SelectedEventView(event: event)
                            .environmentObject(appState)
                            .environmentObject(appState.eventState)) {
                                Text(event.title + " - " + event.creator.username)
                                    .searchCompletion(event.title)
                            }
                    }
                }
                .onChange(of: viewModel.searchText) {
                    viewModel.searchEvents()
                }
                .searchPresentationToolbarBehavior(.avoidHidingContent)
                
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
            .onAppear{
                print(viewModel.events)
            }
            .backgroundStyle(Color.black)
            .foregroundStyle(Color.white)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SearchView(appState: AppState(), eventState: EventState())
        .environmentObject(AppState())
        .environmentObject(AuthState())
        .preferredColorScheme(.dark)
}
