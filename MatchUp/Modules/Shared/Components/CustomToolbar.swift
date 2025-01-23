//
//  CustomToolbar.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 10/12/2024.
//

import SwiftUI

struct CustomToolbar<Content: View>: View {
    @EnvironmentObject var appState: AppState
    var content: Content
    private let selectedIconColor: Color = .white
    
    init(content: @escaping () -> Content) {
            self.content = content()
        }
    
    var body: some View {
        NavigationStack {
                
                content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        print("Friends")
                    }) {
                        Image(systemName: "person.2.fill")
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("MatchUp")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        print("Profile")
                    }) {
                        Image(systemName: "person.circle")
                    }
                }
            }
            .foregroundStyle(Color.white)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CustomToolbar(){
        Text("Hello World")
    }
    .preferredColorScheme(.dark)
}
