//
//  UserService.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 18/01/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserService {
    private let db = Firestore.firestore()
    
    func register(username: String, name: String, surname: String, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                completion(.failure(NSError(domain: "", code: 409, userInfo: [NSLocalizedDescriptionKey: "User already exists"])))
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let uid = authResult?.user.uid else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found"])))
                    return
                }
                
                let userData: [String: Any] = [
                    "uid": uid,
                    "username": username,
                    "name": name,
                    "surname": surname,
                    "email": email,
                    "favourite_sports": [],
                    "user_events": [],
                    "friends": [],
                    "sent_friend_requests": [],
                    "received_friend_requests": [],
                    "user_preferences": [
                        "default_search_distance": "Current City",
                        "enable_notification": true,
                        "notify_24h_before": true,
                        "notify_12h_before": false,
                        "notify_6h_before": false,
                        "notify_3h_before": false,
                        "notify_1h_before": true
                    ]
                ]
                
                self.db.collection("users").document(uid).setData(userData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        let user = User(id: uid, username: username, name: name, surname: surname, email: email)
                        completion(.success(user))
                    }
                }
            }
        }
    }
    
    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = snapshot?.documents.first else {
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Username not found"])))
                return
            }
            
            let data = document.data()
            guard let email = data["email"] as? String else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email not found for this username"])))
                return
            }
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                } else if let authResult = authResult {
                    let user = User(
                        id: authResult.user.uid,
                        username: username,
                        name: data["name"] as? String ?? "",
                        surname: data["surname"] as? String ?? "",
                        email: email,
                        favouriteSports: data["favourite_sports"] as? [String] ?? []
                    )
                    completion(.success(user))
                }
            }
        }
    }
    
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchAllUsers() async throws -> [User] {
        let querySnapshot = try await db.collection("users").getDocuments()
        return querySnapshot.documents.compactMap { document in
            
            let userData = document.data()
           
            return mapUserDataToUser(userData: userData)
        }
    }
    
    func fetchUserFriends(userId: String) async throws -> [String: [User]] {
        let userRef = db.collection("users").document(userId)
        
        let userSnapshot = try await userRef.getDocument()
        
        guard let userData = userSnapshot.data() else {
            throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        guard let userFriends = userData["friends"] as? [String],
              let userFriendRequests = userData["received_friend_requests"] as? [String] else {
            throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Friends not found"])
        }
        
        func fetchUsersByIds(ids: [String]) async throws -> [User] {
            var users: [User] = []
            
            for id in ids {
                let userRef = db.collection("users").document(id)
                
                let userSnapshot = try await userRef.getDocument()
                
                guard let userData = userSnapshot.data(),
                      let user = mapUserDataToUser(userData: userData) else {
                    throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                }
                users.append(user)
            }
            return users
        }
        
        let friends: [User] = try await fetchUsersByIds(ids: userFriends)
        let friendRequests: [User] = try await fetchUsersByIds(ids: userFriendRequests)
        return ["friends": friends, "requests": friendRequests]
    }
    
    func fetchUserPreferences(userId: String) async throws -> [String: Any] {
        let userRef = db.collection("users").document(userId)
        
        let userSnapshot = try await userRef.getDocument()
        
        guard let userData = userSnapshot.data() else {
            throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        guard let userPreferences = userData["user_preferences"] as? [String: Any] else {
            throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User preferences not found"])
        }
        
        return userPreferences
    }
    
    func updateUserProfile(userId: String, userNewData: [String: Any]) async throws {
        let userRef = db.collection("users").document(userId)
       
        do {
            try await userRef.updateData(userNewData)
        } catch {
            throw error
        }
    }
    
    func updateUserProfileInDB(userId: String, userNewData: [String: Any]) async throws {
        let userFieldsToUpdate = [
            "name": userNewData["name"],
            "surname": userNewData["surname"],
            "favourite_sports": userNewData["favourite_sports"]
        ].compactMapValues { $0 }
        
        try await updateUserProfile(userId: userId, userNewData: userNewData)
        
        let currentTimestamp = Timestamp(date: Date())
        let querySnapshot = try await db.collection("events")
            .whereField("date", isGreaterThan: currentTimestamp)
            .getDocuments()
        
        for document in querySnapshot.documents {
            var eventData = document.data()
            let eventRef = document.reference
            
            var shouldUpdate = false
            
            if var creator = eventData["creator"] as? [String: Any], creator["uid"] as? String == userId {
                for (key, value) in userFieldsToUpdate {
                    creator[key] = value
                }
                eventData["creator"] = creator
                shouldUpdate = true
            }
            
            if var participants = eventData["participants"] as? [[String: Any]] {
                var updatedParticipants = participants
                for i in 0..<participants.count {
                    if participants[i]["uid"] as? String == userId {
                        for (key, value) in userFieldsToUpdate {
                            updatedParticipants[i][key] = value
                        }
                        shouldUpdate = true
                    }
                }
                eventData["participants"] = updatedParticipants
            }
            if shouldUpdate {
                try await eventRef.updateData(eventData)
            }
        }
    }
    
    private func mapUserDataToUser(userData: [String: Any]) -> User? {
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
    
    func sendFriendInvitation(senderId: String, receiverId: String) async throws {
        try await db.runTransaction { transaction, errorPointer in
            let senderRef = self.db.collection("users").document(senderId)
            let receiverRef = self.db.collection("users").document(receiverId)
            
            do {
                let senderSnapshot = try transaction.getDocument(senderRef)
                let receiverSnapshot = try transaction.getDocument(receiverRef)
                
                guard let senderData = senderSnapshot.data(), let receiverData = receiverSnapshot.data() else {
                    throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                }
                
                guard var senderFriendRequests = senderData["sent_friend_requests"] as? [String], var receiverFriendRequests = receiverData["received_friend_requests"] as? [String] else {
                    throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Friends not found"])
                }
                
                senderFriendRequests.append(receiverId)
                receiverFriendRequests.append(senderId)
                
                transaction.updateData(["sent_friend_requests": senderFriendRequests], forDocument: senderRef)
                transaction.updateData(["received_friend_requests": receiverFriendRequests], forDocument: receiverRef)
                
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }
    
    func checkInvitationStatus(myUserId: String, otherUserId: String) async throws -> InvitationStatus? {
        try await db.runTransaction { transaction, errorPointer in
            let myUserRef = self.db.collection("users").document(myUserId)
            
            do {
                let myUserSnapshot = try transaction.getDocument(myUserRef)
                
                guard let myUserData = myUserSnapshot.data() else {
                    throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                }
                
                let myUserFriends = myUserData["friends"] as? [String] ?? []
                let myUserFriendRequests = myUserData["sent_friend_requests"] as? [String] ?? []
                
                if myUserFriends.contains(otherUserId) {
                    return "accepted"
                } else if myUserFriendRequests.contains(otherUserId) {
                    return "pending"
                } else {
                    return "notInvited"
                }
                
            } catch {
                errorPointer?.pointee = error as NSError
                return "NotInvited"
            }
        }
        .flatMap { status in
            switch status as? String {
            case "accepted":
                return InvitationStatus.accepted
            case "pending":
                return InvitationStatus.pending
            default:
                return InvitationStatus.notInvited
            }
        }
    }
    
    func addFriend(myUserId: String, otherUserId: String) async throws {
        try await db.runTransaction { transaction, errorPointer in
            let myUserRef = self.db.collection("users").document(myUserId)
            let otherUserRef = self.db.collection("users").document(otherUserId)
            
            do {
                let myUserSnapshot = try transaction.getDocument(myUserRef)
                let otherUserSnapshot = try transaction.getDocument(otherUserRef)
                
                guard let myUserData = myUserSnapshot.data(), let otherUserData = otherUserSnapshot.data() else {
                    throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                }
                
                guard var otherUserFriends = otherUserData["friends"] as? [String], var otherUserFriendRequests = otherUserData["sent_friend_requests"] as? [String] else {
                    throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Friends not found"])
                }
                
                guard var myUserFriends = myUserData["friends"] as? [String], var myUserFriendRequests = myUserData["received_friend_requests"] as? [String] else {
                    throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Friends not found"])
                }
                
                myUserFriends.append(otherUserId)
                otherUserFriends.append(myUserId)
                myUserFriendRequests.removeAll { $0 == otherUserId }
                otherUserFriendRequests.removeAll { $0 == myUserId }
                
                transaction.updateData(["friends": myUserFriends], forDocument: myUserRef)
                transaction.updateData(["received_friend_requests": myUserFriendRequests], forDocument: myUserRef)
                transaction.updateData(["friends": otherUserFriends], forDocument: otherUserRef)
                transaction.updateData(["sent_friend_requests": otherUserFriendRequests], forDocument: otherUserRef)
                
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }
    
    func removeFriend(myUserId: String, otherUserId: String) async throws {
        try await db.runTransaction { transaction, errorPointer in
            let myUserRef = self.db.collection("users").document(myUserId)
            let otherUserRef = self.db.collection("users").document(otherUserId)
            
            do {
                let myUserSnapshot = try transaction.getDocument(myUserRef)
                let otherUserSnapshot = try transaction.getDocument(otherUserRef)
                
                guard let myUserData = myUserSnapshot.data(), let otherUserData = otherUserSnapshot.data() else {
                    throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                }
                
                guard var otherUserFriends = otherUserData["friends"] as? [String] else {
                    throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Friends not found"])
                }
                
                guard var myUserFriends = myUserData["friends"] as? [String] else {
                    throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Friends not found"])
                }
                
                myUserFriends.removeAll { $0 == otherUserId }
                otherUserFriends.removeAll { $0 == myUserId }
                
                transaction.updateData(["friends": myUserFriends], forDocument: myUserRef)
                transaction.updateData(["friends": otherUserFriends], forDocument: otherUserRef)
                
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }
    
    func rejectFriend(myUserId: String, otherUserId: String) async throws {
        try await db.runTransaction { transaction, errorPointer in
            let myUserRef = self.db.collection("users").document(myUserId)
            let otherUserRef = self.db.collection("users").document(otherUserId)
            
            do {
                let myUserSnapshot = try transaction.getDocument(myUserRef)
                let otherUserSnapshot = try transaction.getDocument(otherUserRef)
                
                guard let myUserData = myUserSnapshot.data(), let otherUserData = otherUserSnapshot.data() else {
                    throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                }
                
                guard var otherUserFriendRequests = otherUserData["sent_friend_requests"] as? [String] else {
                    throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Friends not found"])
                }
                
                guard var myUserFriendRequests = myUserData["received_friend_requests"] as? [String] else {
                    throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Friends not found"])
                }
                
                myUserFriendRequests.removeAll { $0 == otherUserId }
                otherUserFriendRequests.removeAll { $0 == myUserId }
                
                transaction.updateData(["sent_friend_requests": myUserFriendRequests], forDocument: myUserRef)
                transaction.updateData(["received_friend_requests": otherUserFriendRequests], forDocument: otherUserRef)
                
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }
}
