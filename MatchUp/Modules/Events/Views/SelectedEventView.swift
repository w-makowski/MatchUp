//
//  SelectedEventView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 01/12/2024.
//

import SwiftUI

struct SelectedEventView: View {
    @EnvironmentObject var eventState: EventState
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authState: AuthState
    var event: Event
    private let selectedIconColor: Color = .white
    
    var body: some View {
                
        VStack() {
            CustomBackButton(text: "Back")
            EventDetail(event: event, appState: appState, eventState: eventState, authState: authState).environmentObject(appState)
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar() {
            ToolbarItem(placement: .principal) {
                Text("MatchUp")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
            }

        }
        .navigationBarBackButtonHidden(true)
        .foregroundStyle(Color.white)
    }
}

//#Preview {
//    let eventState = EventState()
//    eventState.selectedEvent = Event(title: "Sunday Game at Orliki", type: .football, location: "Orliki, Ślęża", date: "10.11.2024", time: "12:30", totalSlots: 10, takenSlots: 5, skillLevel: .beginner, mapImage: "map", description: "akjdhfka jdhfkaj dfhkajshf kjashdfk jashdfk jahsdkajdhf kajdshfk jasdhkfjh aksdjfh aksjdhfk jadhsfkj haksdjfh aksdjhf kajsdhf kjasadsfkjh aksdjfh kadjshfk jadhskf jhadksjhf kasdjhf kajsdhf kjadshfk jashdkj fhaksdjf haksdjhf kasdjhfasdfkj haksdjfh kajdshfk jahsdkfj hkadsjhf kjasdhfk jads kjasdhf  aksjdfhgk jadhf kjahsdfkj hadksjfh kajsh fkajsdhfk jahsdkfj haksjdhf ikajs")
//    SelectedEventView()
//        .environmentObject(eventState)
//    
//}
