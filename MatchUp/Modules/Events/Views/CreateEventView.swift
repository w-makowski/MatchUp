//
//  CreateEventView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 12/12/2024.
//

import SwiftUI

struct CreateEventView: View {
    @StateObject var createEventModel: CreateEventModel
    @State private var showCategoryPicker = false
    @State private var showSkillLevelPicker = false
    @State private var navigateToEvent = false
    @State private var isMapPresented: Bool = false
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authState: AuthState
    
    init(appState: AppState, authState: AuthState) {
        _createEventModel = StateObject(wrappedValue: CreateEventModel(appState: appState, authState: authState))
    }
    
    var body: some View {
        
       NavigationStack {
            
           VStack() {
                   
               Button(action: {
                   createEventModel.reset()
               }) {
                   Text("Reset")
                       .font(.system(size: 17, weight: .semibold))
               }
               .padding()
               
               ScrollView {
                   
                   ZStack {
                       
                       VStack(spacing: 20) {
                           
                           CustomTextField(name: "Event Name", textImage: nil, xOffset: 90, textFieldValue: $createEventModel.eventName)
                               .width(350)
                           
                           Button(createEventModel.address.isEmpty ? "Select Location on Map" : createEventModel.address) {
                               isMapPresented.toggle()
                           }
                           .padding()
                           .frame(width: 320)
                           .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
                           
                           // Date Picker
                           DatePicker("Select Date", selection: $createEventModel.date, displayedComponents: .date)
                               .padding()
                               .frame(width: 320)
                               .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
                           
                           // Time Picker
                           DatePicker("Select Time", selection: $createEventModel.time, displayedComponents: .hourAndMinute)
                               .padding()
                               .frame(width: 320)
                               .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
                           
                           // Category Picker
                           Menu {
                               ForEach(EventType.allCases) { category in
                                   Button(action: {
                                       createEventModel.category = category
                                   }) {
                                       Text(category.description())
                                   }
                               }
                           } label: {
                               HStack {
                                   Text(createEventModel.category?.description() ?? "Category")
                                   Spacer()
                                   Image(systemName: "chevron.up.chevron.down")
                               }
                               .padding()
                               .frame(width: 320)
                               .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
                           }
                           
                           Menu {
                               ForEach(SkillLevel.allCases) { skillLevel in
                                   Button(action: {
                                       createEventModel.skillLevel = skillLevel
                                   }) {
                                       Text(skillLevel.description())
                                   }
                               }
                           } label: {
                               HStack {
                                   Text(createEventModel.skillLevel?.description() ?? "Skill Level")
                                   Spacer()
                                   Image(systemName: "chevron.up.chevron.down")
                               }
                               .padding()
                               .frame(width: 320)
                               .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
                           }
                           
                           TextField("Number of players", value: $createEventModel.numberOfPlayers, formatter: NumberFormatter())
                               .keyboardType(.numberPad)
                               .padding()
                               .frame(width: 320)
                               .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
                           
                           TextEditor(text: $createEventModel.description)
                               .padding()
                               .frame(width: 320, height: 150)
                               .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
                           
                           HStack {
                               Button(action: {
                                   print("Invite Friends")
                               }) {
                                   Text("Invite Friends")
                                       .frame(maxWidth: .infinity)
                                       .frame(width: 140)
                                       .padding()
                                       .background(Color.gray.opacity(0.2))
                                       .cornerRadius(40)
                               }
                               
                               Button(action: {
                                   Task {
                                       await createEventModel.createEvent()
                                       if createEventModel.isEventCreated {
                                           navigateToEvent = true
                                       }
                                   }
                               }) {
                                   Text("Create")
                                       .frame(maxWidth: .infinity)
                                       .frame(width: 140)
                                       .padding()
                                       .background(Color.gray.opacity(0.2))
                                       .cornerRadius(40)
                               }
                               .navigationDestination(isPresented: $navigateToEvent) {
                                   if let event = createEventModel.createdEvent {
                                       SelectedEventView(event: event)
                                           .environmentObject(appState)
                                           .environmentObject(appState.eventState)
                                   } else {
                                       Text("Event could not be loaded.")
                                           .foregroundColor(.red)
                                   }
                               }
                           }
                           
                           Group {
                               if let errorMessage = createEventModel.errorMessage {
                                   Text(errorMessage)
                                       .foregroundColor(.red)
                                   
                               } else {
                                   Text("No Error")
                                       .foregroundStyle(.black)
                               }
                           }
                       }
                   }
               }
               .sheet(isPresented: $isMapPresented) {
                   VStack {
                       HStack {
                           Text("Select Location")
                           Spacer()
                           Button(action: {
                               isMapPresented.toggle()
                           }) {
                               Circle()
                                   .fill(Color.gray)
                                   .frame(width: 30, height: 30)
                                   .overlay(Image(systemName: "xmark")
                                       .foregroundStyle(Color.white))
                           }
                           .padding(.horizontal)
                       }
                       
                       MapView(selectedLocation: $createEventModel.location, onLocationSelected: { location in
                           createEventModel.location = location
                           createEventModel.reverseGeocode(location: location)
                           print(createEventModel.location ?? "null")
                           print(createEventModel.address)
                       })
                   }
                   .padding()
               }
           }
           .onAppear {
               createEventModel.reset()
           }
           .navigationBarTitleDisplayMode(.inline)
           .toolbar() {
               ToolbarItem(placement: .topBarLeading) {
                   NavigationLink(destination: SocialView(appState: appState, authState: authState)) {
                       Image(systemName: "person.2.fill")
                   }
               }
               
               ToolbarItem(placement: .principal) {
                   Text("MatchUp")
                       .font(.system(size: 36, weight: .heavy, design: .rounded))
               }
               
               ToolbarItem(placement: .topBarTrailing) {
                   NavigationLink(destination: MyProfileView(appState: appState, authState: authState)) {
                       Image(systemName: "person.circle")
                   }
               }
           }
        }
    }
}

#Preview {
    
    CreateEventView(appState: AppState(), authState: AuthState())
        .environmentObject(AppState())
        .environmentObject(AuthState())
}
