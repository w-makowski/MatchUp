//
//  MyProfileView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 12/12/2024.
//

import SwiftUI

struct MyProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @State private var showEditView: Bool = false
    
    init(appState: AppState, authState: AuthState) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(appState: appState, authState: authState))
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
                    Text(viewModel.getUsername())
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                }
            }
            
            ScrollView {
                
                VStack {
                    
                    ZStack {
                        Rectangle()
                            .fill(Color(red: 0.44, green: 0.44, blue: 0.44))
                            .aspectRatio(1.0, contentMode: .fit)
                        
                        Text(viewModel.getUsername().prefix(1).uppercased())
                            .font(.system(size: 128, weight: .medium))
                        
                        Text(viewModel.getName() + " " + viewModel.getSurname())
                            .font(.system(size: 36, weight: .semibold))
                            .offset(x: -80, y: 180)
                    }
                    .padding(.bottom, 40)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("Personal Details")
                                .font(.system(size: 20, weight: .semibold))
                                .padding(.leading, 15)
                            Spacer()
                        }
                        
                        CustomTextField(name: "Name", textImage: nil, textFieldValue: $viewModel.name, textPlaceholder: viewModel.getName())
                        
                        CustomTextField(name: "Surname", textImage: nil, textFieldValue: $viewModel.surname, textPlaceholder: viewModel.getSurname())
                            
                        // Favourite sports
                        HStack {
                            ZStack {
                                    
                                ScrollView {
                                    Text(viewModel.createFavouriteSportsText())
                                        .padding()
                                        .padding(.top, 5)
                                }
                                .frame(width: 320, height: 70)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.white, lineWidth: 1.5)
                                )
                                
                                HStack {
                                    Text("Favourite Sports")
                                }
                                .padding(.horizontal, 10)
                                .background(Color.black)
                                .position(x: 90, y: 15)
                            }
                            .frame(width: 330, height: 100)
                            
                            Button(action: {
                                showEditView.toggle()
                            }) {
                                Text("Edit")
                            }
                            .sheet(isPresented: $showEditView) {
                                FavouriteSportsEditView(viewModel: viewModel)
                            }
                        }
                        
                        // Default search distance
                        HStack {
                            
                            Text("Default search distance:")
                            
                            Spacer()
                            
                            Menu {
                                ForEach(eventDistances, id: \.self) { distance in
                                    Button(action: {
                                        viewModel.defaultSearchDistance = distance
                                    }) {
                                        Text(distance)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.defaultSearchDistance)
                                    //Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 20)
                        
                        HStack {
                            Text("Notifications")
                                .font(.system(size: 20, weight: .semibold))
                                .padding(.leading, 15)
                            Spacer()
                        }
                        
                        Toggle("Enable notification about your events", isOn: $viewModel.enableNotification)
                            .tint(Color.blue)
                            .padding(.horizontal, 15)
                        
                        HStack {
                            Text("Notification frequency before an event:")
                                .padding(.leading, 15)
                            Spacer()
                        }
                        
                        Toggle("24h before:", isOn: $viewModel.notify24hBefore)
                            .tint(Color.blue)
                            .padding(.horizontal, 15)
                        
                        Toggle("12h before:", isOn: $viewModel.notify12hBefore)
                            .tint(Color.blue)
                            .padding(.horizontal, 15)
                        
                        Toggle("6h before:", isOn: $viewModel.notify6hBefore)
                            .tint(Color.blue)
                            .padding(.horizontal, 15)
                        
                        Toggle("3h before:", isOn: $viewModel.notify3hBefore)
                            .tint(Color.blue)
                            .padding(.horizontal, 15)
                        
                        Toggle("1h before:", isOn: $viewModel.notify1hBefore)
                            .tint(Color.blue)
                            .padding(.horizontal, 15)
                        
                        Button(action: {
                            viewModel.updateUserProfile()
                        }) {
                            Text("Save changes")
                                .font(.system(size: 17, weight: .semibold))
                                .frame(width: 140, height: 42)
                                .clipShape(RoundedRectangle(cornerRadius: 40))
                                .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                                .foregroundStyle(Color.white)
                                .clipShape(.rect(cornerRadius: 40))
                        }
                            .labelStyle(.titleOnly)
                            .buttonStyle(.borderless)
                        
                        Button(action: {
                            viewModel.logout()
                        }) {
                            Text("Log out")
                                .font(.system(size: 17, weight: .semibold))
                                .frame(width: 140, height: 42)
                                .clipShape(RoundedRectangle(cornerRadius: 40))
                                .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                                .foregroundStyle(Color.red)
                                .clipShape(.rect(cornerRadius: 40))
                        }
                            .labelStyle(.titleOnly)
                            .buttonStyle(.borderless)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    let appState = AppState()
    let authState = AuthState()
    MyProfileView(appState: appState, authState: authState)
        .preferredColorScheme(.dark)
}
