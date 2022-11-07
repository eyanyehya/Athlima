//
//  Post.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/18/22.
//  Post model

import Foundation
import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

// Sport enum with different sports
enum Sport: String, Codable, CaseIterable {
    case none = ""
    case soccer = "Soccer"
    case basketball = "Basketball"
    case tennis = "Tennis"
    case baseball = "Baseball"
    case golf = "Golf"
    case running = "Running"
    case volleyball = "Volleyball"
    case badminton = "Badminton"
    case swimming = "Swimming"
    case boxing = "Boxing"
    case tabletennis = "Tabletennis"
    case skiing = "Skiing"
    case cricket = "Cricket"
    case rugby = "Rugby"
    case football = "Football"
    case cycling = "Cycling"
    case surfing = "Surfing"
    case gymnastics = "Gymnastics"
    case martialArts = "Martial Arts"
    case other = "Other"
}

// Level enum showcasing different skill levels
enum Level: String, Codable, CaseIterable {
    case Recreational = "Recreational"
    case LowerIntermediate = "Lower Intermediate"
    case Intermediate = "Intermediate"
    case UpperIntermediate = "Upper Intermediate"
    case Competitive = "Competitive"
    case VeryCompetitive = "Very Competitive"
}

// Age enum showcasing different age groups
enum Age: String, Codable, CaseIterable {
    case noPreference = "All Ages"
    case Youngteenager = "10-16"
    case OldTeenager = "17-19"
    case EarlyTwenties = "20-25"
    case LateTwenties = "25-30"
    case Thirties = "30-40"
    case Fourties = "40-50"
    case Fifties = "50-60"
    case overFifty = "60+"
}

// struct with info on the posts location (to show map)
struct LocationInfo: Codable, Equatable, Identifiable {
    var name: String
    var countryCode: String
    var coordinate:  Coordinate
    var id = UUID()
}

// Coordinate with lat and long values to init map
struct Coordinate: Codable, Hashable {
    let latitude, longitude: Double
}

// Post struct with fields that will be shown when a post is shown
struct Post: Identifiable, Codable, Equatable {
    var title: String
    var description: String
    var time: Date
    var timePosted = Date()
    var sport: Sport
    var phoneNumber: String
    var location: LocationInfo
    var playersMissing: Int
    var level: Level
    var ageRequired: Age
    var id = UUID()
    var author: User
    var usersAttending: [DocumentReference]
    
    func contains(_ string: String) -> Bool {
        // properties of the post that contains is being called on so x in the case x.contains(y) and query is y
        // used in search bar
        let properties = [title, description, author.name, sport.rawValue, location.countryCode].map { $0.lowercased() }
        let query = string.lowercased()
        
        // if one of the properties contains the input string matches will not be empty so true is returned
        let matches = properties.filter { $0.contains(query) }
        return !matches.isEmpty
    }
    
    enum CodingKeys: CodingKey {
        case title, description, time, timePosted, sport, phoneNumber, location, id, playersMissing, level, ageRequired, author, usersAttending
    }
}

extension Post {
    static let testPost = Post(title: "Title", description: "kdjfh dfkjh dkfjhdfkj dfh djkfhkjdf df dfh jdfh kjdfh dfh jkdfh dfhdkjf dfh ", time: Date(), sport: .badminton, phoneNumber: "438 9307112", location: LocationInfo(name: "", countryCode: "", coordinate: Coordinate(latitude: 45.50537692974784, longitude: -73.57919454574585)), playersMissing: 0, level: .Competitive, ageRequired: .EarlyTwenties, author: User.testUser, usersAttending: [])
}
