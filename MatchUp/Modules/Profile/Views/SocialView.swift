//
//  SocialView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 14/12/2024.
//

import SwiftUI

struct SocialView: View {
    private var appState: AppState
    @StateObject var viewModel: SocialViewModel
    @State private var isShowingRequests = false
    @State private var userToRemove: User?
    @State private var showConfirmationDialog = false
    
    init(appState: AppState, authState: AuthState) {
        _viewModel = StateObject(wrappedValue: SocialViewModel(appState: appState, authState: authState))
        self.appState = appState
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 5) {

                    VStack {
                        Button(action: {
                            print("link")
                        }) {
                            HStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 40, height: 40)
                                    .overlay(Text(viewModel.getUserSymbol()))
                                    .padding(.trailing)
                                
                                VStack {
                                    Text("Invite friends on MatchUp")
                                    Text(viewModel.obtainUserLink())
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .padding(.horizontal)
                                
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 28, weight: .regular))
                                    .padding(.leading)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20)
                        }
                        .padding(.bottom)
                        
                        HStack {
                            if isShowingRequests {
                                Text("Friend requests")
                                Spacer()
                                Button("Friends") {
                                    isShowingRequests.toggle()
                                }
                                .clipShape(Rectangle())
                                .frame(width: 80, height: 30)
                                .background(Color(red: 0.47, green: 0.47, blue: 0.50).opacity(0.24))
                                .cornerRadius(40);
                            } else {
                                Text("My Friends (\(viewModel.friends.count))")
                                Spacer()
                                Button("Requests") {
                                    isShowingRequests.toggle()
                                }
                                .clipShape(Rectangle())
                                .frame(width: 80, height: 30)
                                .background(Color(red: 0.47, green: 0.47, blue: 0.50).opacity(0.24))
                                .cornerRadius(40);
                            }
                        }
                        .padding()
                        
                        VStack {
                            if isShowingRequests {
                                ScrollView {
                                    VStack(spacing: 10) {
                                        ForEach(viewModel.friendRequests) { user in
                                            NavigationLink(destination: OtherUserProfileView(user: user, appState: appState, authUser: viewModel.getAuthUser())) {
                                                FriendRequestRow(user: user, acceptAction: {
                                                    viewModel.acceptRequest(user)
                                                }, rejectAction: {
                                                    userToRemove = user
                                                    showConfirmationDialog.toggle()
                                                })
                                            }
                                        }
                                    }
                                }
                                
                            } else {
                                ScrollView {
                                    VStack(spacing: 10) {
                                        ForEach(viewModel.friends) { user in
                                            //NavigationStack {
                                            NavigationLink(destination: OtherUserProfileView(user: user, appState: appState, authUser: viewModel.getAuthUser())) {
                                                FriendRow(user: user, action: {
                                                    userToRemove = user
                                                    showConfirmationDialog.toggle()
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .confirmationDialog(
                            isShowingRequests ? "Are you sure you want to reject this friend request?" : "Are you sure you want to remove this friend?",
                            isPresented: $showConfirmationDialog,
                            titleVisibility: .visible
                        ) {
                            
                            Button(isShowingRequests ? "Reject Request" : "Remove", role: .destructive) {
                                if let user = userToRemove {
                                    if isShowingRequests {
                                        viewModel.rejectRequest(user)
                                    } else {
                                        viewModel.removeFriend(user)
                                    }
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                        
                        Spacer()
                    }
                    .safeAreaInset(edge: .top, content: {
                        Color.clear.frame(height: 20)
                    })
                    .onAppear {
                        viewModel.searchText = ""
                    }
                    .searchable(text: $viewModel.searchText,
                                placement: .navigationBarDrawer(displayMode: .always),
                                prompt: "Search friends"
                    )
                    .searchSuggestions {
                        ForEach(viewModel.suggestedUsers) { user in
                            NavigationLink(destination: OtherUserProfileView(user: user, appState: appState, authUser: viewModel.getAuthUser())) {
                                Text(user.username)
                                    .searchCompletion(user.username)
                            }
                        }
                    }
                    .onChange(of: viewModel.searchText) {
                        viewModel.searchUsers()
                    }
                    .searchPresentationToolbarBehavior(.avoidHidingContent)
                    
                }
                
                Spacer()
                
            }
        
        .navigationBarTitleDisplayMode(.inline)
        .toolbar() {
            ToolbarItem(placement: .topBarLeading) {
                    CustomBackButton(text: nil)
                }
            
            ToolbarItem(placement: .principal) {
                Text("MatchUp")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
            }
            }
        
        
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let appState = AppState()
    let authState = AuthState()
    SocialView(appState: appState, authState: authState)
        .preferredColorScheme(.dark)
}
