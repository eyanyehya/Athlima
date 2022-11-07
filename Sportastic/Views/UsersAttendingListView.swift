//
//  UsersAttendingListView.swift
//  Sportastic
//
//  Created by Eyan Yehya on 10/3/22.
//  

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UsersAttendingListView: View {
    var postId: UUID
    @State var users: [User]
    
    var body: some View {
        if users.isEmpty {
            EmptyListView(
                title: "No attendees",
                message: "No one has joined your event yet"
            )
        }
        List(users) { user in
            VStack {
                ProfileImage(url: user.imageURL)
                    .frame(width: 200, height: 200)
                
                Grid() {
                    GridRow {
                        Text("Name")
                        Spacer()
                        Text(user.name)
                    }
                    Divider()
                    GridRow {
                        Text("Email")
                        Spacer()
                        Text("\(user.email)")
                    }
                    Divider()
                    GridRow {
                        Text("Phone Number")
                        Spacer()
                        Link(destination: URL(string: "tel:\(formatPhoneNumber(number: user.phoneNumber))")!, label: { Text("\(user.phoneNumber)").font(.callout).foregroundColor(.blue) })
                    }
                    Divider()
                    GridRow {
                        Text("Age")
                        Spacer()
                        Text("\(getAgeFromBirthday(birthday: user.birthday))")
                    }
                }
            }
        }
        .onAppear(perform: { getUsersAttendingEventTask(withID: postId) })
    }
    
    func formatPhoneNumber (number: String) -> String {
        var formattedNumber: String = ""
        for char in number {
            if char.isNumber {
                formattedNumber.append(char)
            }
        }
        return formattedNumber
    }
    
    func getUsersAttendingEvent(withID id: UUID) async throws {
        let postsReference = Firestore.firestore().collection("posts")
        let usersReference = Firestore.firestore().collection("users")
        
        let event = try await postsReference.whereField("id", isEqualTo: id.uuidString).getDocuments(as: Post.self)
        
        // get array of ID's of all the users attending the event
        let ids: [String]  = event[0].usersAttending.map({ $0.documentID })
        
        if ids.isEmpty {
            return
        }
        
        users = try await fetchUsers(from: usersReference.whereField("id", in: ids))
    }
    
    func getUsersAttendingEventTask(withID id: UUID) {
        Task {
            try await getUsersAttendingEvent(withID: id)
        }
    }
    
    func fetchUsers(from query: Query) async throws -> [User] {
        let users = try await query.getDocuments(as: User.self)
        return users
    }
    
    func getAgeFromBirthday(birthday: Date) -> Int {
        return Calendar.current.dateComponents([.year, .month, .day], from: birthday, to: Date()).year ?? 0
    }
}

struct UsersAttendingListView_Previews: PreviewProvider {
    static var previews: some View {
        UsersAttendingListView(postId: UUID(), users: [])
    }
}
