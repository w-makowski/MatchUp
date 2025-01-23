//
//  EventService.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 18/01/2025.
//

import Foundation
import FirebaseFirestore
import CoreLocation

class EventService {
    private let db = Firestore.firestore()
    
    func fetchAllEvents() async throws -> [Event] {
        let querySnapshot = try await db.collection("events").getDocuments()
        return querySnapshot.documents.compactMap { document in
            
            let eventId = document.documentID
            
            let eventData = document.data()
           
            return mapEventDataToEvent(eventId: eventId, eventData: eventData)
        }
    }
    
    func fetchFutureEvents() async throws -> [Event] {
        let currentTimestamp = Timestamp(date: Date())
        let querySnapshot = try await db.collection("events")
            .whereField("date", isGreaterThan: currentTimestamp)
            .getDocuments()
        
        return querySnapshot.documents.compactMap { document in
            let eventId = document.documentID
            let eventData = document.data()
            return mapEventDataToEvent(eventId: eventId, eventData: eventData)
        }
    }
    
    func addEvent(_ event: Event) async throws -> DocumentReference {
        let eventData: [String: Any] = [
            "title": event.title,
            "creator": [
                "uid": event.creator.id,
                "username": event.creator.username,
                "name": event.creator.name,
                "surname": event.creator.surname,
                "email": event.creator.email,
                "favourite_sports": event.creator.favouriteSports
            ],
            "type": event.type.description(),
            "location": [
                "latitude": event.location.latitude,
                "longitude": event.location.longitude
            ],
            "address": event.address,
            "search_address": event.searchAddress,
            "date": Timestamp(date: event.date),
            "total_slots": event.totalSlots,
            "taken_slots": event.takenSlots,
            "skill_level": event.skillLevel.description(),
            "participants": event.participants.map { user -> [String: Any] in
                return [
                    "uid": user.id,
                    "username": user.username,
                    "name": user.name,
                    "surname": user.surname,
                    "email": user.email,
                    "favourite_sports": user.favouriteSports
                ]
            },
            "description": event.description
        ]
        
        do {
            let docRef = try await db.collection("events").addDocument(data: eventData)
            
            return docRef
        } catch {
            throw NSError(domain: "EventService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to add event"])
        }
    }
    
    
    func checkIfUserIsInEvent(userId: String, eventId: String) async throws -> Bool {
        let eventRef = db.collection("events").document(eventId)
        
        let eventSnapshot = try await eventRef.getDocument()
        
        guard let eventData = eventSnapshot.data() else {
            throw NSError(domain: "EventService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Event not found"])
        }
        
        if let participants = eventData["participants"] as? [[String: Any]] {
            for participant in participants {
                if let uid = participant["uid"] as? String, uid == userId {
                    return true
                }
            }
        }
        return false
    }
    
    func addUserToEvent(userId: String, eventId: String) async throws {
        try await db.runTransaction { transaction, errorPointer in
                // Odwołanie do dokumentu wydarzenia
            let eventRef = self.db.collection("events").document(eventId)
            let userRef = self.db.collection("users").document(userId)
                
            do {
                let eventSnapshot = try transaction.getDocument(eventRef)
                
                guard let eventData = eventSnapshot.data(),
                      let eventDate = eventData["date"] as? Timestamp,
                      let eventTitle = eventData["title"] as? String,
                      let totalSlots = eventData["total_slots"] as? Int,
                      var takenSlots = eventData["taken_slots"] as? Int,
                      var eventParticipants = eventData["participants"] as? [[String: Any]] else {
                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Event not found or invalid data."])
                }
                
                if takenSlots >= totalSlots {
                    throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "No seats available."])
                }
                
                let userSnapshot = try transaction.getDocument(userRef)
                
                guard let userData = userSnapshot.data(),
                      var userEvents = userData["user_events"] as? [[String: Any]] else {
                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found or invalid data."])
                }
                
                guard let userUID = userData["uid"] as? String,
                      let userUsername = userData["username"] as? String,
                      let userName = userData["name"] as? String,
                      let userSurname = userData["surname"] as? String,
                      let userEmail = userData["email"] as? String,
                      let userFavSports = userData["favourite_sports"] as? [String] else {
                    throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "User data is incomplete."])
                }
                
                takenSlots += 1
                transaction.updateData(["taken_slots": takenSlots], forDocument: eventRef)
                
                userEvents.append([
                    "event_id": eventId,
                    "event_date": eventDate,
                    "event_title": eventTitle
                    ])
                transaction.updateData(["user_events": userEvents], forDocument: userRef)
                
                eventParticipants.append([
                    "uid": userUID,
                    "username": userUsername,
                    "name": userName,
                    "surname": userSurname,
                    "email": userEmail,
                    "favourite_sports": userFavSports
                ])
                transaction.updateData(["participants": eventParticipants], forDocument: eventRef)
                
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }
    
    func removeUserFromEvent(userId: String, eventId: String) async throws {
        try await db.runTransaction { transaction, errorPointer in
            let eventRef = self.db.collection("events").document(eventId)
            let userRef = self.db.collection("users").document(userId)
                
            do {
                let eventSnapshot = try transaction.getDocument(eventRef)
                
                guard let eventData = eventSnapshot.data(),
                      var takenSlots = eventData["taken_slots"] as? Int,
                      var eventParticipants = eventData["participants"] as? [[String: Any]] else {
                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Event not found or invalid data."])
                }
                
                if takenSlots > 0 {
                    takenSlots -= 1
                }
                
                let userSnapshot = try transaction.getDocument(userRef)
                
                guard let userData = userSnapshot.data(),
                      var userEvents = userData["user_events"] as? [[String: Any]] else {
                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found or invalid data."])
                }
                
                eventParticipants.removeAll { participant in
                    guard let uid = participant["uid"] as? String else { return false }
                    return uid == userId
                }
                
                userEvents.removeAll { event in
                    guard let userEventId = event["event_id"] as? String else { return false }
                    return userEventId == eventId
                }
                
                transaction.updateData(["user_events": userEvents], forDocument: userRef)
                
                transaction.updateData(["taken_slots": takenSlots], forDocument: eventRef)
                
                transaction.updateData(["participants": eventParticipants], forDocument: eventRef)
                
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }
    
    func fetchUserEvents(userId: String) async throws -> [Event] {
        let userRef = db.collection("users").document(userId)
        let userSnapshot = try await userRef.getDocument()
        
        guard let userData = userSnapshot.data() else {
            throw NSError(domain: "UserSerivce", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        guard let userEventsElements = userData["user_events"] as? [[String: Any]], !userEventsElements.isEmpty else {
            return []
        }
        
        let eventsCollection = db.collection("events")
        var userEvents: [Event] = []
        
        for eventElement in userEventsElements {
            guard let eventId = eventElement["event_id"] as? String else { continue }
            
            let eventSnapshot = try await eventsCollection.document(eventId).getDocument()
            
            guard let eventData = eventSnapshot.data() else { continue }
            
            if let event = mapEventDataToEvent(eventId: eventId, eventData: eventData) {
                userEvents.append(event)
            }
        }
        
        return userEvents
    }
    
    private func mapEventDataToEvent(eventId: String, eventData: [String: Any]) -> Event? {
        guard let title = eventData["title"] as? String,
              let creatorDict = eventData["creator"] as? [String: Any],
              let typeString = eventData["type"] as? String,
              let locationData = eventData["location"] as? [String: Double],
              let latitude = locationData["latitude"],
              let longitude = locationData["longitude"],
              let address = eventData["address"] as? String,
              let searchAddress = eventData["search_address"] as? String,
              let dateTimestamp = eventData["date"] as? Timestamp,
              let totalSlots = eventData["total_slots"] as? Int,
              let takenSlots = eventData["taken_slots"] as? Int,
              let skillLevelString = eventData["skill_level"] as? String,
              let users = eventData["participants"] as? [[String: Any]],
              let description = eventData["description"] as? String else {
            return nil
        }
        
        let date = dateTimestamp.dateValue()
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let type = EventType.from(string: typeString)!
        let skillLevel = SkillLevel.from(string: skillLevelString)!
        
        let participants: [User] = users.compactMap { userData in
            guard let uid = userData["uid"] as? String,
                  let username = userData["username"] as? String,
                  let name = userData["name"] as? String,
                  let surname = userData["surname"] as? String,
                  let email = userData["email"] as? String,
                  let favouriteSports = userData["favourite_sports"] as? [String] else {
                return nil
            }
            return User(id: uid, username: username, name: name, surname: surname, email: email, favouriteSports: favouriteSports)
        }
        
        guard let creatorUid = creatorDict["uid"] as? String,
              let creatorUsername = creatorDict["username"] as? String,
              let cratorName = creatorDict["name"] as? String,
              let creatorSurname = creatorDict["surname"] as? String,
              let creatorEmail = creatorDict["email"] as? String,
              let creatorFavouriteSports = creatorDict["favourite_sports"] as? [String] else {
            return nil
        }
        
        let creator = User(id: creatorUid, username: creatorUsername, name: cratorName, surname: creatorSurname, email: creatorEmail, favouriteSports: creatorFavouriteSports)
        
        let event = Event(id: eventId,
                          title: title,
                          creator: creator,
                          type: type,
                          location: location,
                          address: address,
                          searchAddress: searchAddress,
                          date: date,
                          totalSlots: totalSlots,
                          takenSlots: takenSlots,
                          skillLevel: skillLevel,
                          participants: participants,
                          description: description)
        
        return event
    }

    func updateEventSeatsAndUserEvents(eventId: String, userId: String) async throws {
        try await db.runTransaction { transaction, errorPointer in
            let eventRef = self.db.collection("events").document(eventId)
            let userRef = self.db.collection("users").document(userId)
                
                do {
                    let eventSnapshot = try transaction.getDocument(eventRef)
                    
                    guard let eventData = eventSnapshot.data(),
                          let totalSlots = eventData["total_slots"] as? Int,
                          var takenSlots = eventData["taken_slots"] as? Int,
                          var eventParticipants = eventData["participants"] as? [[String: Any]] else {
                        throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Event not found or invalid data."])
                    }
                    
                    if takenSlots >= totalSlots {
                        throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "No seats available."])
                    }
                    
                    takenSlots += 1
                    transaction.updateData(["taken_slots": takenSlots], forDocument: eventRef)
                    
                    let userSnapshot = try transaction.getDocument(userRef)
                    
                    guard let userData = userSnapshot.data(),
                          var userEvents = userData["user_events"] as? [String] else {
                        throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found or invalid data."])
                    }
                    
                    userEvents.append(eventId)
                    transaction.updateData(["user_events": userEvents], forDocument: userRef)
                    
                    guard let userUID = userData["uid"] as? String,
                          let userUsername = userData["username"] as? String,
                          let userName = userData["name"] as? String,
                          let userSurname = userData["surname"] as? String,
                          let userEmail = userData["email"] as? String,
                          let userFavSports = userData["favourite_sports"] as? [String] else {
                        throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "User data is incomplete."])
                    }
                    
                    eventParticipants.append([
                        "uid": userUID,
                        "username": userUsername,
                        "name": userName,
                        "surname": userSurname,
                        "email": userEmail,
                        "favourite_sports": userFavSports
                    ])
                    transaction.updateData(["participants": eventParticipants], forDocument: eventRef)
                    
                    return nil
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }
    }

    func fetchEvent(eventId: String) async throws -> Event {
        let eventRef = db.collection("events").document(eventId)
        
        let eventSnapshot = try await eventRef.getDocument()
        
        guard let eventData = eventSnapshot.data() else {
            throw NSError(domain: "EventService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Event not found"])
        }
        
        if let event = mapEventDataToEvent(eventId: eventId, eventData: eventData) {
            return event
        } else {
            throw NSError(domain: "EventService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Event not found"])
        }
    }
}
