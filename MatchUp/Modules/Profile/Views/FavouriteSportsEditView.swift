//
//  FavouriteSportsEditView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 16/12/2024.
//

import SwiftUI

struct FavouriteSportsEditView: View {
    @StateObject var viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                }
                List {
                    ForEach(viewModel.favouriteSports, id: \.self) { sport in
                        Text(sport)
                    }
                    .onDelete {viewModel.favouriteSports.remove(atOffsets: $0)}
                    .onMove { viewModel.favouriteSports.move(fromOffsets: $0, toOffset: $1) }
                }
                .navigationTitle("Favourite Sports")
                .toolbar {
                    HStack {
                        Menu {
                            ForEach(Array(favouriteSportsData.keys), id: \.self) { sport in
                                Button(action: {
                                    viewModel.favouriteSports.append(sport)
                                }) {
                                    Label(sport, systemImage: favouriteSportsData[sport]!)
                                }
                            }
                        } label: {
                            HStack {
                                Label("Add", systemImage: "plus")
                            }
                            .padding()
                        }
                        EditButton()
                    }
                }
            }
        }
    }
}

#Preview {
    let appState = AppState()
    let authState = AuthState()
    
    FavouriteSportsEditView(viewModel: ProfileViewModel(appState: appState, authState: authState))
        .preferredColorScheme(.dark)
}
