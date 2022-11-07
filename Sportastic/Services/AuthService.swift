//
//  AuthService.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/18/22.
//  File that handles the creation of a user, sign in and out and updating the users profile image

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation
import CoreLocationUI

@MainActor
class AuthService: ObservableObject {
    @Published var user: User?
    
    // referencing the collection storing our users
    let usersReference = Firestore.firestore().collection("users")

    private let auth = Auth.auth()
    
    // listener that runs everytime the auth state is changed so when account is created, user signs in and user signs out
    private var listener: AuthStateDidChangeListenerHandle?
 
    init() {
        listener = auth.addStateDidChangeListener { [weak self] _, user in
            self?.user = user.map { User(from: $0) }
        }
    }
    
    // function that creates a user and creates a user document to access extra fields that cannot be accessed using FirebaseAuth.User
    func createAccount(name: String, email: String, password: String, birthday: Date, phoneNumber: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        // set display name (on firebase) to name from user input
        try await result.user.updateProfile(\.displayName, to: name)
        
        // adding entry to users collection
        let document = usersReference.document(result.user.uid)
        try await document.setData(from: User(id: result.user.uid, name: name, email: email, birthday: birthday, phoneNumber: phoneNumber, usersPosts: [], eventsAttending: []))
        
        // change user name from "" to the actual input
        user?.name = name
    }
    
    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func updateProfileImage(to imageFileURL: URL?) async throws {
        guard let user = auth.currentUser else {
            preconditionFailure("Cannot update profile for nil user")
        }
        guard let imageFileURL = imageFileURL else {
            try await user.updateProfile(\.photoURL, to: nil)
            if let photoURL = user.photoURL {
                try await StorageFile.atURL(photoURL).delete()
            }
            return
        }
        async let newPhotoURL = StorageFile
            .with(namespace: "users", identifier: user.uid)
            .putFile(from: imageFileURL)
            .getDownloadURL()
        
        // update in user collection!
        try await usersReference.document(user.uid).updateData(["imageURL": newPhotoURL.absoluteString])
        try await user.updateProfile(\.photoURL, to: newPhotoURL)
    }
}

private extension User {
    // creates new user object when AuthService is initialized with id given by firebase and display name of "" which is then updated when user creates account
    init(from firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.name = firebaseUser.displayName ?? ""
        self.email = firebaseUser.email ?? ""
        self.imageURL = firebaseUser.photoURL
        self.birthday = Date()
        self.phoneNumber = ""
        self.usersPosts = []
        self.eventsAttending = []
    }
}

private extension FirebaseAuth.User {
    func updateProfile<T>(_ keyPath: WritableKeyPath<UserProfileChangeRequest, T>, to newValue: T) async throws {
        var profileChangeRequest = createProfileChangeRequest()
        profileChangeRequest[keyPath: keyPath] = newValue
        try await profileChangeRequest.commitChanges()
    }
}
