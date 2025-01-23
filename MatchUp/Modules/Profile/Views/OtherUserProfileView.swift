//
//  OtherUserProfileView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 15/12/2024.
//

import SwiftUI

struct OtherUserProfileView: View {
    @StateObject var viewModel: OtherUserProfileViewModel
    @EnvironmentObject var appState: AppState
    
    init(user: User, appState: AppState, authUser: User) {
        _viewModel = StateObject(wrappedValue: OtherUserProfileViewModel(user: user, appState: appState, authUser: authUser))
    }
    
    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                HStack {
                    CustomBackButton(text: nil)
                        .font(.system(size: 17, weight: .semibold))
                }
                .padding(.horizontal, 15)
                
                VStack {
                    Text(viewModel.user.username)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                }
            }
            
            ZStack {
                Rectangle()
                    .fill(Color(red: 0.35, green: 0.35, blue: 0.35))
                    .aspectRatio(1.0, contentMode: .fit)
                
                Text(viewModel.user.username.prefix(1).uppercased())
                    .font(.system(size: 128, weight: .medium))
                
                Text(viewModel.user.name + " " + viewModel.user.surname)
                    .font(.system(size: 36, weight: .semibold))
                    .offset(x: -80, y: 180)
            }
            .padding(.bottom, 40)
            
            ZStack {
                ScrollView {
                    Text(viewModel.createFavouriteSportsText())
                        .padding()
                        .padding(.top, 5)
                }
                    .frame(width: 370, height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                          .stroke(.white, lineWidth: 1.5)
                    )
                    .padding()
                
                HStack {
                    Text("Favourite Sports")
                }
                    .padding(.horizontal, 10)
                    .background(Color.black)
                    .position(x: 110, y: 15)
            }
            .frame(height: 100)
            
            
            if viewModel.isOtherUserProfile {
                Button(action: { viewModel.handleInvitationButton()
                }) {
                    HStack {
                        Image(systemName: viewModel.selectInviteButtonImage())
                        Text(viewModel.selectInviteButtonText())
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.white, lineWidth: 1.5))
                    
                }
                .background(Color.black)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.top, 25)
            } else {
                Text("This is your profile")
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.white, lineWidth: 1.5))
                    .background(Color.black)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 25)
            }
            Spacer()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    let appState = AppState()
    OtherUserProfileView(user: user1, appState: appState, authUser: user0).environmentObject(appState)
        .preferredColorScheme(.dark)
}
