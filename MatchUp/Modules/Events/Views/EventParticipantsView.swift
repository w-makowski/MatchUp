//
//  EventParticipantsView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 08/01/2025.
//

import SwiftUI

struct EventParticipantsView: View {
    @ObservedObject var viewModel: EventViewModel
    
    var body: some View {
        VStack {
            
            HStack {
                Spacer()
                
                Button(action: {
                    viewModel.showParticipantsSheet.toggle()
                }) {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 30, height: 30)
                        .overlay(Image(systemName: "xmark")
                            .foregroundStyle(Color.white))
                }
                .padding(.horizontal)
            }
            
            Text(viewModel.event.title)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .padding()
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.getParticipants()) { user in
                        NavigationLink(destination: OtherUserProfileView(user: user, appState: viewModel.appState, authUser: viewModel.getAuthUser())) {
                            HStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 40, height: 40)
                                    .overlay(Text(user.username.prefix(1).uppercased()))
                                
                                VStack(alignment: .leading) {
                                    Text("\(user.name) \(user.surname)")
                                        .font(.headline)
                                    Text(user.username)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
}

//#Preview {
//    EventParticipantsView(viewModel: EventViewModel(event: Event(title: "Sunday Game at Orliki", creator: user1, type: .football, location: "Orliki, Ślęża", date: Event.customFormatter.convertToDate("10.11.2024 12:30")!, totalSlots: 10, takenSlots: 5, skillLevel: .beginner, mapImage: "map",participants: [user2, user3] , description: "akjdhfka jdhfkaj dfhkajshf kjashdfk jashdfk jahsdkajdhf kajdshfk jasdhkfjh aksdjfh aksjdhfk jadhsfkj haksdjfh aksdjhf kajsdhf kjasadsfkjh aksdjfh kadjshfk jadhskf jhadksjhf kasdjhf kajsdhf kjadshfk jashdkj fhaksdjf haksdjhf kasdjhfasdfkj haksdjfh kajdshfk jahsdkfj hkadsjhf kjasdhfk jads kjasdhf  aksjdfhgk jadhf kjahsdfkj hadksjfh kajsh fkajsdhfk jahsdkfj haksjdhf ikajs"), appState: AppState(), eventState: EventState(), authState: AuthState()))
//}
