//
//  CurrentUserViewModel.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/21/22.
//  View Model that gets the current user who is logged in

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class CurrentUserViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var currentUser: User?
    
    // function that gets the current user
    func getUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Could not find firebase uid"
            return
        }
        
        // if we have a user logged in
        Firestore.firestore().collection("users")
            .document(uid).getDocument { snapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch current user: \(error)"
                    return
                }
                
                // dictionary eg. ["phoneNumber": 4389307115, "name": User 4, "email": u4@gmail.com, "id": wfhJTKM6K6UJX7OhvERhkmhVxgV2, "birthday": <FIRTimestamp: seconds=822196800 nanoseconds=0>]
                guard let data = snapshot?.data() else {
                    self.errorMessage = "No data found"
                    return
                }
                
                // get each field from the dictionary
                let name = data["name"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let id = data["id"] as? String ?? ""
                let phoneNumber = data["phoneNumber"] as? String ?? ""
                let birthday = data["birthday"] as? Timestamp ?? Timestamp(date: Date())
                //                let age = self.getAgeFromBirthday(birthday: birthday.dateValue())
                self.currentUser = User(id: id, name: name, email: email, birthday: birthday.dateValue(), phoneNumber: phoneNumber, usersPosts: [], eventsAttending: [])
            }
    }
    
    // function that deletes a users account from FireBase
    func deleteUser(){
        // get the current user
        let user = Auth.auth().currentUser
        
        // get current users uid
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Could not find firebase uid"
            return
        }
                
        Firestore.firestore().collection("users").document(userId).delete() { err in
            if let err = err {
                print("error: \(err)")
            } else {
                user?.delete { error in
                    if let error = error {
                        // An error happened.
                        print("Error \(error)")
                    } else {
                        // Account deleted.
                        print("Account deleted")
                    }
                }
            }
        }
    }
    
    func getAgeFromBirthday(birthday: Date) -> Int {
        return Calendar.current.dateComponents([.year, .month, .day], from: birthday, to: Date()).year ?? 0
    }
}
