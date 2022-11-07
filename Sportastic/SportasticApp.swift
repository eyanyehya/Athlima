//
//  SportasticApp.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/18/22.
//

import SwiftUI
import Firebase

@main
struct SportasticApp: App {
    
    // set up firebase
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            // the app begins at the AuthView()
            AuthView()
        }
    }
}
