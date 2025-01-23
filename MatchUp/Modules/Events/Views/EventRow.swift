//
//  EventRow.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 30/11/2024.
//

import SwiftUI
import MapKit

struct EventRow: View {
    @State private var region: MKCoordinateRegion
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var event: Event
    
    init(event: Event) {
        self.event = event
        _region = State(initialValue: MKCoordinateRegion(
            center: event.location,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        cameraPosition = .region(region)
    }
    
    var body: some View {
        HStack {
            Map(position: $cameraPosition, interactionModes: []) {
                Marker("", coordinate: event.location)
                    .tint(.red)
            }
            .clipped()
            .onAppear {
                cameraPosition = .region(region)
            }
                .frame(width: 112, height: 183)
                .cornerRadius(10)
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 207, height: 58)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: event.type.imageSymbol())
                        Text(event.type.description())
                    }
                    
                    HStack {
                        Image(systemName: "map")
                        Text(event.address)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text(event.date.formatted(Date.FormatStyle()
                            .day(.twoDigits)
                            .month(.twoDigits)
                            .year()
                            .locale(Locale(identifier: "pl"))
                             ))
                        Image(systemName: "clock")
                        Text(event.date, format: .dateTime.hour().minute())
                    }
                    
                    HStack {
                        Image(systemName: "person.3.fill")
                        Text(String(event.takenSlots) + "/" + String(event.totalSlots))
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                    
            }
            .foregroundColor(.white)
            .padding(.trailing, 5)
        }
        .frame(width: 330, height: 183)
        .background(Color(red: 0.23, green: 0.23, blue: 0.23))
        .cornerRadius(20)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackgroundVisibility(.automatic, for: .navigationBar)
        .toolbarBackgroundVisibility(.automatic, for: .tabBar)
    }
}

#Preview {
    EventRow(event: event1)
}
