//
//  MainView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 03/12/2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authState: AuthState
    
    private let selectedIconColor: Color = .white

    var body: some View {
        
        VStack(spacing: 0) {
            
            switch appState.currentTab {
            case .home:
                NavigationStack {
                    HomeView(appState: appState, eventState: appState.eventState)
                        .environmentObject(appState)
                        .environmentObject(authState)
                        .navigationBarBackButtonHidden(true)
                }
            case .search:
                SearchView(appState: appState, eventState: appState.eventState)
                    .environmentObject(appState)
                    .environmentObject(authState)
            case .create:
                CreateEventView(appState: appState, authState: authState)
            case .myEvents:
                MyEventsView()
                    .environmentObject(appState)
                    .environmentObject(appState.eventState)
            case .calendar:
                if authState.isAuthenticated {
                    CalendarView(eventState: appState.eventState, authUserId: authState.currentUser!.id)
                        .environmentObject(appState)
                }
            }
            
            TabView(selection: $appState.currentTab) {
                Color.clear
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(Tab.home)
                
                Color.clear
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(Tab.search)
                
                Color.clear
                    .tabItem {
                        Label("Create", systemImage: "plus.circle")
                    }
                    .tag(Tab.create)
                
                Color.clear
                    .tabItem {
                        Label("MyEvents", systemImage: "e.square")
                    }
                    .tag(Tab.myEvents)
                
                Color.clear
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .tag(Tab.calendar)
                
            }
            .frame(maxWidth: .infinity, maxHeight: 40)
            .tint(appState.currentTab.isValidTab ? selectedIconColor : .gray)
        }
    }
    
}

extension Tab {
    var isValidTab: Bool {
        switch self {
        case .home, .search, .create, .myEvents, .calendar:
            return true
        default:
            return false
        }
    }
}


#Preview {
    let appState = AppState()
    let authState = AuthState()
    MainView().environmentObject(appState).environmentObject(authState)
        .preferredColorScheme(.dark)
}
