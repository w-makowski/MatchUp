//
//  PreviewData.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 21/01/2025.
//

import Foundation
import CoreLocation

var event1 = Event(id: "1", title: "Sunday Game at Orliki", creator: user1, type: .football, location: CLLocationCoordinate2D(latitude: 51.123456789, longitude: 17.0987654321), address: "Orliki, Ślęża", searchAddress: "Orliki, Ślęża, Dolnośląskie", date: Event.customFormatter.convertToDate("23.11.2024 12:30")!, totalSlots: 10, takenSlots: 5, skillLevel: .beginner, description: "")
var event2 = Event(id: "2", title: "Football Match", creator: user2, type: .football, location: CLLocationCoordinate2D(latitude: 51.123456789, longitude: 17.0987654321), address: "Orlik, Wrocław", searchAddress: "Orliki, Ślęża, Dolnośląskie", date: Event.customFormatter.convertToDate("27.01.2025 14:00")!, totalSlots: 10, takenSlots: 7, skillLevel: .intermediate, description: "")
var event3 = Event(id: "3", title: "Football Practice", creator: user2, type: .football, location: CLLocationCoordinate2D(latitude: 51.123456789, longitude: 17.0987654321), address: "Korty Piłkarskie, Wrocław", searchAddress: "Orliki, Ślęża, Dolnośląskie", date: Event.customFormatter.convertToDate("26.11.2024 10:00")!, totalSlots: 5, takenSlots: 2, skillLevel: .beginner, description: "")
var event4 = Event(id: "4", title: "Game at Orliki", creator: user3, type: .football, location: CLLocationCoordinate2D(latitude: 51.123456789, longitude: 17.0987654321), address: "Orliki, Ślęża", searchAddress: "Orliki, Ślęża, Dolnośląskie", date: Event.customFormatter.convertToDate("24.01.2025 12:30")!, totalSlots: 10, takenSlots: 5, skillLevel: .beginner, description: "")
var event5 = Event(id: "5", title: "Football Match", creator: user1, type: .football, location: CLLocationCoordinate2D(latitude: 51.123456789, longitude: 17.0987654321), address: "Orlik, Wrocław", searchAddress: "Orliki, Ślęża, Dolnośląskie", date: Event.customFormatter.convertToDate("11.11.2024 14:00")!, totalSlots: 10, takenSlots: 7, skillLevel: .intermediate, description: "")
var event6 = Event(id: "6", title: "Football Practice", creator: user2, type: .football, location: CLLocationCoordinate2D(latitude: 51.123456789, longitude: 17.0987654321), address: "Korty Piłkarskie, Wrocław", searchAddress: "Orliki, Ślęża, Dolnośląskie", date: Event.customFormatter.convertToDate("27.01.2025 10:00")!, totalSlots: 5, takenSlots: 2, skillLevel: .beginner, participants: [user0], description: "")

var user0 = User(id: "0", username: "johndavis", name: "John", surname: "Davis", email: "john@davis.com", favouriteSports: ["Football", "Volleyball", "Basketball"])
var user2 = User(id: "1", username: "andy.andy", name: "Andy", surname: "Andy", email: "andy@andy.andy", favouriteSports: ["Soccer", "Swimming"])
var user1 = User(id: "2", username: "frank.smith1", name: "Frank", surname: "Smith", email: "", favouriteSports: ["Football", "Volleyball", "Basketball"])
var user3 = User(id: "3", username: "jane.doe", name: "Jane", surname: "Doe", email: "jane@doe.com", favouriteSports: ["Golf", "Tennis", "Cycling"])
var user4 = User(id: "4", username: "johnsmith", name: "John", surname: "Smith", email: "john@smith.com", favouriteSports: ["Running", "Swimming", "Basketball"])
var user5 = User(id: "5", username: "johndoe", name: "John", surname: "Doe", email: "john@doe.com", favouriteSports: ["Football", "Swimming", "Basketball"])
var user6 = User(id: "6", username: "johnny123", name: "Johnny", surname: "Smith", email: "johnny@smith.com", favouriteSports: [])

var usersDatabase: [User] = [user0, user1, user2, user3, user4, user5, user6]

var usersEvents: [User: [Event]] = [user0: [event1, event2], user1: [], user2: [], user3: [], user4: [], user5: [], user6: []]


