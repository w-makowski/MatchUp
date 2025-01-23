//
//  User.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 28/11/2024.
//

import Foundation

class User: Identifiable, Hashable, Equatable {
    var id: String
    var username: String
    var name: String
    var surname: String
    var email: String
    var profilePictureURL: String? = nil
    var favouriteSports: [String] = []
    
    init(id: String, username: String, name: String, surname: String, email: String, favouriteSports: [String]) {
        self.id = id
        self.username = username
        self.name = name
        self.surname = surname
        self.email = email
        self.favouriteSports = favouriteSports
    }
    
    init(id: String, username: String, name: String, surname: String, email: String) {
        self.id = id
        self.username = username
        self.name = name
        self.surname = surname
        self.email = email
    }
    
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
