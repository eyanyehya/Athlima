//
//  User.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/18/22.
//  User model 

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Identifiable, Codable, Equatable {
    // unique id of user
    var id: String
    
    // name of user
    var name: String
    
    // email of user
    var email: String
    
    // birthday of user
    var birthday: Date
    
    // phone number of user
    var phoneNumber: String
    
    // posts that the user has made
    var usersPosts: [DocumentReference]
    
    // events that the user is attending
    var eventsAttending: [DocumentReference]
    
    // profile photo
    var imageURL: URL?

}

extension User {
    static let testUser = User(
        id: "",
        name: "Jamie Harris",
        email: "j@gmail.com",
        birthday: Date(),
        phoneNumber: "123",
        usersPosts: [],
        eventsAttending: [],
        imageURL: URL(string: "https://source.unsplash.com/lw9LrnpUmWw/480x480")
    )
}
