//
//  FriendRow.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 05/01/2025.
//

import SwiftUI

struct FriendRow: View {
    let user: User
    let action: () -> Void
    
    var body: some View {
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
            
            Button(action: action) {
                Image(systemName: "xmark")
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .contentShape(Rectangle())
        .padding(.horizontal)
    }
}

struct FriendRequestRow: View {
    let user: User
    let acceptAction: () -> Void
    let rejectAction: () -> Void
    
    var body: some View {
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
            
            Button(action: acceptAction) {
                Text("Accept")
                    .clipShape(Rectangle())
                    .frame(width: 80, height: 30)
                    .background(Color(red: 0.47, green: 0.47, blue: 0.50).opacity(0.24))
                    .cornerRadius(40);
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding()
            
            Button(action: rejectAction) {
                Image(systemName: "xmark")
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .contentShape(Rectangle())
        .padding(.horizontal)
    }
}

#Preview {
    FriendRow(user: user2, action: {})
    FriendRequestRow(user: user2, acceptAction: {}, rejectAction: {})
}

//#Preview {
//    let appState = AppState()
//    let authState = AuthState()
//    FriendRow2(appState: appState, authState: authState)
//}
