//
//  FiltersView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 02/12/2024.
//

import SwiftUI

struct FiltersView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        HStack {
            Text("Filters")
                .font(.system(size: 25, weight: .semibold))
            Spacer()
            Button(action: {
                viewModel.showFilters.toggle()
            }) {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 30, height: 30)
                    .overlay(Image(systemName: "xmark")
                        .foregroundStyle(Color.white))
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 20)
        .padding(.horizontal, 10)
        .padding(.top, 10)
        
        TextField("Select Location", text: $viewModel.location, onEditingChanged: { isEditing in
            viewModel.isSearching = isEditing }, onCommit: {
                viewModel.isSearching = false
            })
            .padding()
            .frame(width: 320)
            .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
            .disabled(viewModel.distance != nil)
            .onChange(of: viewModel.location) {
                viewModel.performActionOnChange()
            }
            .padding(.bottom, 20)
            .overlay(
                Group {
                    if viewModel.isSearching && !viewModel.searchResults.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(viewModel.searchResults, id: \.self) { item in
                                    Button(action: {
                                        viewModel.handleSelectSearchLocation(item: item)
                                    }) {
                                        Text(viewModel.formatAddress(from: item))
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.gray.opacity(0.2))
                                    }
                                }
                            }
                            .background(Color.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                        .frame(height: 200)
                    }
                }
                .padding(.horizontal, 20),
                alignment: .top
            )
        
        Menu {
            ForEach(eventDistances, id: \.self) { distance in
                Button(action: {
                    viewModel.distance = distance
                }) {
                    Text(distance)
                }
            }
        }
        label: {
            HStack {
                Text(viewModel.distance ?? "Distance")
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
            }
            .padding()
            .frame(width: 320)
            .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
        }
        .disabled(!viewModel.location.isEmpty)
        .padding(.bottom, 20)
        
        // Date Picker
        DatePicker("Select Date",
                   selection: Binding (
                    get: { viewModel.date ?? Date() },
                    set: { viewModel.date = $0 }
                   ),
                   displayedComponents: .date
        )
            .padding()
            .frame(width: 320)
            .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
            .padding(.bottom, 20)
        
        // Time Picker
        DatePicker("Select Time",
                   selection:  Binding (
                    get: { viewModel.time ?? Date() },
                    set: { viewModel.time = $0 }
                   ),
                   displayedComponents: .hourAndMinute
        )
            .padding()
            .frame(width: 320)
            .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
            .padding(.bottom, 20)
        
        // Category Picker
        Menu {
            ForEach(EventType.allCases) { category in
                Button(action: {
                    viewModel.category = category
                }) {
                    Text(category.description())
                }
            }
        } label: {
            HStack {
                Text(viewModel.category?.description() ?? "Category")
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
            }
            .padding()
            .frame(width: 320)
            .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
        }
        .padding(.bottom, 20)
        
        Menu {
            ForEach(SkillLevel.allCases) { skillLevel in
                Button(action: {
                    viewModel.skillLevel = skillLevel
                }) {
                    Text(skillLevel.description())
                }
            }
        } label: {
            HStack {
                Text(viewModel.skillLevel?.description() ?? "Skill Level")
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
            }
            .padding()
            .frame(width: 320)
            .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
        }
        .padding(.bottom, 20)
        
        HStack {
            Text("Number of players:")
            Spacer()
            TextField("Min", text: $viewModel.minNumberOfPlayers)
                .padding()
                .frame(width: 65, height: 28)
                .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
                .keyboardType(.numberPad)
            Text("-")
            TextField("Max", text: $viewModel.maxNumberOfPlayers)
                .padding()
                .frame(width: 65, height: 28)
                .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
                .keyboardType(.numberPad)
        }
        .frame(width: 320)
        .padding(.bottom, 20)
        
        Toggle("Show only events I can join", isOn: $viewModel.showOnlyEventsICanJoin)
            .tint(Color.blue)
            .frame(width: 320)
            .padding(.bottom, 20)
        
        Group {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                
            } else {
                Text(" ")
                    .foregroundStyle(.black)
            }
        }
            .padding(.bottom, 20)
        
        
        HStack {
            Button(action: {
                viewModel.resesetFilters()
            }) {
                Text("Reset")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 160, height: 45)
                    .background(Color(red: 0.47, green: 0.47, blue: 0.50).opacity(0.24))
                    .clipShape(RoundedRectangle(cornerRadius: 40))
            }
            
            Button(action: {
                viewModel.filter()
                viewModel.showFilters.toggle()
            }) {
                Text("Filter")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 160, height: 45)
                    .background(Color(red: 0.47, green: 0.47, blue: 0.50).opacity(0.24))
                    .clipShape(RoundedRectangle(cornerRadius: 40))
            }
        }
        
        //Spacer()
    }
}

#Preview {
    FiltersView(viewModel: SearchViewModel(appState: AppState(), eventState: EventState()))
        .preferredColorScheme(.dark)
}
