//
//  UserInfoViewModel.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/20/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserInfoViewModel {
    func getUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        Firestore.firestore().collection("users")
            .document(uid).getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch current user \(error)")
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                print(data)
            }
    }
}
