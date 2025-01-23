//
//  Event.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 30/11/2024.
//

import Foundation
import MapKit

struct CustomFormatter {
    let formatter = DateFormatter()
    
    init () {
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
    }
    
    func convertToDate(_ string: String) -> Date? {
        formatter.date(from: string)
    }
}


class Event: Identifiable, Equatable {
    //let id: UUID = UUID()
    var id: String
    var title: String
    let creator: User
    var type: EventType
    var location: CLLocationCoordinate2D
    var address: String
    var searchAddress: String
    var date: Date //Date
    //var time: String
    var totalSlots: Int
    @Published var takenSlots: Int
    var skillLevel: SkillLevel
    var participants: [User] = []
    var description: String
    
    init(id: String, title: String, creator: User, type: EventType, location: CLLocationCoordinate2D, address: String, searchAddress: String, date: Date, totalSlots: Int, takenSlots: Int, skillLevel: SkillLevel, description: String) {
        self.id = id
        self.title = title
        self.creator = creator
        self.type = type
        self.location = location
        self.address = address
        self.searchAddress = searchAddress
        self.date = date
        self.totalSlots = totalSlots
        self.takenSlots = takenSlots
        self.skillLevel = skillLevel
        self.participants = []
        self.description = description
    }
    
    init(id: String, title: String, creator: User, type: EventType, location: CLLocationCoordinate2D, address: String, searchAddress: String, date: Date, totalSlots: Int, takenSlots: Int, skillLevel: SkillLevel, participants: [User], description: String) {
        self.id = id
        self.title = title
        self.creator = creator
        self.type = type
        self.location = location
        self.address = address
        self.searchAddress = searchAddress
        self.date = date
        self.totalSlots = totalSlots
        self.takenSlots = takenSlots
        self.skillLevel = skillLevel
        self.participants = participants
        self.description = description
    }
    
    init(title: String, creator: User, type: EventType, location: CLLocationCoordinate2D, address: String, searchAddress: String, date: Date, totalSlots: Int, takenSlots: Int, skillLevel: SkillLevel, description: String) {
        self.id = "0"
        self.title = title
        self.creator = creator
        self.type = type
        self.location = location
        self.address = address
        self.searchAddress = searchAddress
        self.date = date
        self.totalSlots = totalSlots
        self.takenSlots = takenSlots
        self.skillLevel = skillLevel
        self.participants = []
        self.description = description
    }
    
    static func ==(lhs: Event, rhs: Event) -> Bool {
           return lhs.id == rhs.id
       }
    
    static let customFormatter = CustomFormatter()
    
//    static var sampleData = [
//        event1,
//        event2,
//        event3,
//        event4,
//        event5,
//        event6
//    ]
    
    func geocodeAddress(address: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let location = placemarks?.first?.location {
                completion(.success(location.coordinate))
            } else {
                completion(.failure(NSError(domain: "GeocodingError", code: -1, userInfo: nil)))
            }
        }
    }

    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D, completion: @escaping (Result<String, Error>) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let placemark = placemarks?.first {
                let address = [placemark.thoroughfare, placemark.locality]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                completion(.success(address))
            } else {
                completion(.failure(NSError(domain: "ReverseGeocodingError", code: -1, userInfo: nil)))
            }
        }
    }

    
//    func skillLevelDescription() -> String {
//        switch skillLevel {
//            case .beginner: return "Beginner"
//            case .intermediate: return "Intermediate"
//            case .advanced: return "Advanced"
//        }
//    }
}

extension CLLocationCoordinate2D {
    func toCLLocation() -> CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
}

enum EventType: CaseIterable, Identifiable {
    case football
    
    var id: String { description() }
    
    func imageSymbol() -> String {
        switch self {
            case .football: return "soccerball"
        }
    }
    
    func description() -> String {
        switch self {
            case .football: return "Football"
        }
    }
    
    static func from(string: String) -> EventType? {
        switch string.lowercased() {
        case "football":
            return .football
        default:
            return nil
        }
    }
    
}

enum SkillLevel: CaseIterable, Identifiable {
    case beginner
    case intermediate
    case advanced
    
    var id: String { description() }
    
    func description() -> String {
        switch self {
            case .beginner: return "Beginner"
            case .intermediate: return "Intermediate"
            case .advanced: return "Advanced"
        }
    }
    
    static func from(string: String) -> SkillLevel? {
        switch string.lowercased() {
        case "beginner":
            return .beginner
        case "intermediate":
            return .intermediate
        case "advanced":
            return .advanced
        default:
            return nil
        }
    }
}

enum MyEventsTab: String {
    case all = "All"
    case created = "Created"
    case joined = "Joined"
}

let eventDistances: [String] = ["Current City", "300m", "500m", "1km", "2km", "5km", "10km", "15km", "20km", "30km", "50km", "100km", "150km", "200km"]

let favouriteSportsData: [String: String] = [
    "Football": "soccerball",
    "Volleyball": "volleyball",
    "Basketball": "basketball",
    "Hockey": "hockey.puck",
    "Baseball": "baseball",
    "Tennis": "tennisball",
    "Golf": "figure.golf",
    "Swimming": "figure.pool.swim",
    "Running": "figure.run",
    "Cycling": "figure.outdoor.cycle",
    "Skiing": "figure.skiing.downhill",
    "Snowboarding": "figure.snowboarding",
    "Surfing": "figure.surfing",
    "Skateboarding": "figure.skateboarding",
    "Boxing": "figure.boxing",
    "Wrestling": "figure.wrestling",
    "Badminton": "figure.badminton",
    "Cricket": "cricket.ball",
    "American Football": "football",
    "Bowling": "figure.bowling",
    "Archery": "figure.archery",
    "Table Tennis": "figure.table.tennis",
    "Martial Arts": "figure.martial.arts",
    "Gymnastics": "figure.gymnastics",
    "Weightlifting": "figure.strengthtraining.traditional",
    "Climbing": "figure.climbing",
    "Equestrian": "figure.equestrian.sports",
    "Fencing": "figure.fencing",
    "Shooting": "target",
    "Karate": "figure.martial.arts",
    "Dancing": "figure.dance",
    "Sailing": "sailboat",
    "Rowing": "figure.outdoor.rowing",
    "Fishing": "fish",
    "Ice Skating": "figure.ice.skating",
    "Billiards": "circle.grid.3x3.fill",
    "Motor Sports": "car",
    "Esports": "gamecontroller",
    "Waterpolo": "figure.waterpolo"
]

