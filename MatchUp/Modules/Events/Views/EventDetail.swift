//
//  EventDetail.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 01/12/2024.
//

import SwiftUI
import MapKit

struct EventDetail: View {
    //var event: Event
    @StateObject var viewModel: EventViewModel
    @EnvironmentObject var appState: AppState
    @State private var region: MKCoordinateRegion
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showAlert = false
    
    init(event: Event, appState: AppState, eventState: EventState, authState: AuthState) {
        _viewModel = StateObject(wrappedValue: EventViewModel(event: event, appState: appState, eventState: eventState, authState: authState))
        _region = State(initialValue: MKCoordinateRegion(
            center: event.location,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
        cameraPosition = .region(region)
    }
    
    var body: some View {
        ZStack {
            VStack {
                Map(position: $cameraPosition, interactionModes: []) {
                    Marker("", coordinate: viewModel.event.location)
                        .tint(.red)
                }
                .onAppear {
                    cameraPosition = .region(region)
                }
                .onTapGesture {
                    showAlert.toggle()
                }
                
                .frame(height: 190)
                .cornerRadius(20)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Open Apple Maps"),
                        message: Text("Do you want to open Apple Maps to get directions to this event?"),
                        primaryButton: .default(Text("Yes")) {
                            openAppleMaps()
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                VStack(alignment: .leading) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.event.title)
                            .font(.system(size: 23, weight: .semibold))
                            .frame(height: 58)
                    }
                    .padding(.bottom, 4)
                    
                    NavigationLink(destination:
                                    OtherUserProfileView(user: viewModel.event.creator, appState: appState, authUser: viewModel.authState.currentUser!)) {
                            Image(systemName: "person.fill")
                        Text(viewModel.event.creator.name + " " + viewModel.event.creator.surname)
                        }
                    
                    .padding(.bottom, 4)
                    
                    HStack {
                        Image(systemName: viewModel.event.type.imageSymbol())
                        Text(viewModel.event.type.description())
                    }
                    .padding(.bottom, 4)
                    
                    
                    HStack {
                        Image(systemName: "map")
                        Text(viewModel.event.address)
                    }
                    .padding(.bottom, 4)
                    
                    HStack {
                        HStack {
                            Image(systemName: "calendar")
                            Text(viewModel.event.date, format: .dateTime.day().month().year())
                        }
                        .padding(.trailing)
                        HStack {
                            Image(systemName: "clock")
                            Text(viewModel.event.date, format: .dateTime.hour().minute())
                        }
                    }
                    .padding(.bottom, 4)
                    
                    HStack {
                        HStack {
                            Image(systemName: "star")
                            Text(viewModel.event.skillLevel.description())
                        }
                        .padding(.trailing)
                        HStack {
                            Image(systemName: "person.3.fill")
                            Text(String(viewModel.event.takenSlots) + "/" + String(viewModel.event.totalSlots))
                        }
                    }
                }
                .frame(width: 282)
                
                ScrollView {
                    Text(viewModel.event.description)
                        .padding()
                }
                    .frame(width: 282, height: 130)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                          .inset(by: 0.50)
                          .stroke(.white, lineWidth: 0.50)
                    )
                    .padding()
                
                HStack {
                    Text("Description")
                }
                    .padding(.horizontal, 10)
                    .background(Color(red: 0.23, green: 0.23, blue: 0.23))
                    .position(x: 100, y: -155)
                
                if viewModel.isUserInEvent {
                    
                    HStack {
                        Button(action: {
                            print("Who's in?")
                            viewModel.showParticipants()
                        }) {
                            Text("Who's in?")
                                .font(.system(size: 15, weight: .semibold))
                                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                                .frame(width: 140, height: 42)
                                .background(Color(red: 0.47, green: 0.47, blue: 0.50).opacity(0.24))
                                .cornerRadius(40);
                        }
                        .offset(y: -15)
                        .sheet(isPresented: $viewModel.showParticipantsSheet) {
                            EventParticipantsView(viewModel: viewModel)
                        }
                        
                        Button(action: {
                            viewModel.leaveEvent()
                        }) {
                            Text("Leave")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.red)
                                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                                .frame(width: 140, height: 42)
                                .background(Color(red: 0.47, green: 0.47, blue: 0.50).opacity(0.24))
                                .cornerRadius(40);
                        }
                        .disabled(viewModel.hasEventEnded)
                        .offset(y: -15)
                    }
                    
                } else {
                    Button(action: {
                        viewModel.joinEvent()
                    }) {
                        Text("Join")
                            .font(.system(size: 15, weight: .semibold))
                            .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                            .frame(width: 140, height: 42)
                            .background(Color(red: 0.47, green: 0.47, blue: 0.50).opacity(0.24))
                            .cornerRadius(40);
                    }
                    .disabled(viewModel.hasEventEnded || viewModel.event.takenSlots == viewModel.event.totalSlots)
                    .offset(y: -15)
                }
                
                Spacer()
            }
        }
        .foregroundStyle(.white)
        .frame(width: 336, height: 637)
        .background(Color(red: 0.23, green: 0.23, blue: 0.23))
        .cornerRadius(20)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackgroundVisibility(.automatic, for: .navigationBar)
        .toolbarBackgroundVisibility(.automatic, for: .tabBar)
    }
    
    
    private func openAppleMaps() {
        let destinationCoordinate = viewModel.event.location
        let urlString = "maps://?daddr=\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)"
        
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Apple Maps not available.")
        }
    }
}

#Preview {
    EventDetail(event: event1, appState: AppState(), eventState: EventState(), authState: AuthState())
        .environmentObject(AppState())
}
