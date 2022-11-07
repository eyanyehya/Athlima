//
//  PostRepository.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/18/22.
//  Posts repository that interacts with firebase and handles actions to do with users and posts collections and documents

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol PostsRepositoryProtocol {
    func create(_ post: Post) async throws
    func delete(_ post: Post) async throws
    func join(_ post: Post) async throws
    func fetchAllPosts() async throws -> [Post]
    func fetchCurrentUsersPosts() async throws -> [Post]
    func fetchCurrentUserEventsAttending() async throws -> [Post]
    func fetchPosts(by author: User) async throws -> [Post]
    var user: User { get }
}

struct PostsRepository: PostsRepositoryProtocol {
    // post reference in firebase
    let postsReference = Firestore.firestore().collection("posts")
    
    // user reference in firebase
    let usersReference = Firestore.firestore().collection("users")
    
    // current user
    let user: User
    
    // function that creates a new post
    func create(_ post: Post) async throws {
        // STEP 1: Get current user (so we can access their phone number that cannot be accessed with the current User instance and update their usersPosts array)
        // get the user document for the current user (if this is the users first post
        let userDocument = usersReference.document(user.id)
        
        // convert the document into a User
        let user: User = try await userDocument.getDocument(as: User.self)
        
        // STEP 2: Create new document using the uuid of the post object that is being created
        let document = postsReference.document(post.id.uuidString)
        
        // create a post to be saved in the post document using values from the user 
        let postToBeSaved = Post(title: post.title, description: post.description, time: post.time, sport: post.sport, phoneNumber: user.phoneNumber, location: post.location, playersMissing: post.playersMissing, level: post.level, ageRequired: post.ageRequired, id: post.id,
                                 author:
                                    User(id: user.id, name: user.name, email: user.email, birthday: user.birthday, phoneNumber: user.phoneNumber, usersPosts: user.usersPosts, eventsAttending: user.eventsAttending, imageURL: user.imageURL),
                                 usersAttending: post.usersAttending)
        
        // set the data of the document to the post
        try await document.setData(from: postToBeSaved)
        
        // update the usersPosts array in the user document for the current user to include the event that they are creating
        try await userDocument.updateData(["usersPosts": FieldValue.arrayUnion([document])])
    }
    
    // function that deletes a post
    func delete(_ post: Post) async throws {
        // check if the current user has the authority to delete the post
        precondition(canDelete(post))
        
        // get the post document
        let document = postsReference.document(post.id.uuidString)
        
        // delete the post
        try await document.delete()
    }
    
    // function that allows current user to join an event
    func join(_ post: Post) async throws {
        // PART 1: Update the users eventsAttending array to indicate that they are attending the event
        
        // get user document so we know which user we are updating the array of events attending for
        let userDocument = usersReference.document(user.id)
        
        // get reference to post document (post that is being joined) so we can append it to the eventsAttending array of the current user
        let postReference = postsReference.document(post.id.uuidString)
        
        // append the post being joined to the user who is joining's list of events attending
        try await userDocument.updateData(["eventsAttending": FieldValue.arrayUnion([postReference])])
        
        // PART 2: Update the event that the current user is attending to reflect that they are attending the event
        try await postReference.updateData(["usersAttending": FieldValue.arrayUnion([userDocument])])
        
        // PART 3: Update the number of people attending the post to reflect the need for one less person
        try await postReference.updateData(["playersMissing": FieldValue.increment(-1.0)])
    }
    
    // function that fetches all posts
    func fetchAllPosts() async throws -> [Post] {
        // get all events that are starting in the future
        let postsSortByTime = try await fetchPosts(from: postsReference.whereField("time", isGreaterThan: Date()))
        
        // return the list of posts that are "valid"
        // a valid post is one that the current user has NOT created, the number of missing players is GREATER THAN 0 and the user is NOT ATTENDING
        return postsSortByTime.filter({ post in
            // get the list of users attending the event
            let usersAttendingEvent = post.usersAttending.map({ $0.documentID })
            
            // check conditions mentioned above so only the valid posts are returned
            return post.author.id != user.id && post.playersMissing > 0 && !usersAttendingEvent.contains(user.id)
        })
    }
    
    // function that fetches all posts by a specific author
    // only returns valid posts where a valid post in one that:
    // 1) happens in the future 2) has at least 1 player missing 3) the current user HAS NOT joined yet
    func fetchPosts(by author: User) async throws -> [Post] {
        // get all posts by the given author
        let postsByAuthor = try await fetchPosts(from: postsReference.whereField("author.id", isEqualTo: author.id))
        
        // return valid posts by the author
        return postsByAuthor.filter({ post in
            // get the list of users attending the event
            let usersAttendingEvent = post.usersAttending.map({ $0.documentID })
            
            return post.time > Date() && post.playersMissing > 0 && !usersAttendingEvent.contains(user.id)
        })
    }
    
    // function that fetches the events that the current user is attending
    func fetchCurrentUserEventsAttending() async throws -> [Post] {//
        // get the current user
        let currentUser: [User] = try await usersReference.whereField("id", isEqualTo: user.id).getDocuments(as: User.self)
        
        // get the events that the current user is attending
        let eventsAttending = currentUser[0].eventsAttending.map({ $0.documentID })
        
        // if the user is not attending any events return empty list
        if eventsAttending.isEmpty {
            return []
        }
        
        // if the user is attending events
        
        // fetch all posts that are in the eventsAttending list of the current user
        // i.e get all events that the useris attending
        let postsUserIsAttending = try await fetchPosts(from: postsReference.whereField("id", in: eventsAttending))
        
        // return only the events that are happening in the future, have 0 or more missing players
        return postsUserIsAttending.filter({ post in
            return post.time > Date() && post.playersMissing >= 0
        })
    }
    
    // function that fetches the current users posts
    func fetchCurrentUsersPosts() async throws -> [Post] {
        // get the current user
        let currentUser: [User] = try await usersReference.whereField("id", isEqualTo: user.id).getDocuments(as: User.self)
        
        print("Current user is \(currentUser)")
        
        // get a list of all the events that the user has created (their ids)
        let eventsCreated = currentUser[0].usersPosts.map({ $0.documentID })
        
        print("eventsCreated IDs is \(eventsCreated)")

        
        // if the list is empty return []
        if eventsCreated.isEmpty {
            return []
        }
        
        // if the user has at least one events created
        // get the events that the user created
        let postsByUser = try await fetchPosts(from: postsReference.whereField("id", in: eventsCreated))
        
        print("eventsCreated is \(postsByUser)")

        
        // return posts that are happening in the future
        return postsByUser.filter({ post in
            return post.time > Date()
        })
    }
}

private extension PostsRepository {
    // function that fetches posts from firebase based on a query and returns a list of Posts
    func fetchPosts(from query: Query) async throws -> [Post] {
        let posts = try await query.getDocuments(as: Post.self)
        return posts
    }
}

extension PostsRepositoryProtocol {
    // check to see if a post can be deleted
    func canDelete(_ post: Post) -> Bool {
        post.author.id == user.id
    }
}


#if DEBUG
struct PostsRepositoryStub: PostsRepositoryProtocol {
    let state: Loadable<[Post]>
    
    func fetchAllPosts() async throws -> [Post] {
        return try await state.simulate()
    }
    
    func fetchPosts(by author: User) async throws -> [Post] {
        return try await state.simulate()
    }
    
    func fetchCurrentUserEventsAttending() async throws -> [Post] {
        return try await state.simulate()
    }
    
    func fetchCurrentUsersPosts() async throws -> [Post] {
        return try await state.simulate()
    }
    
    func create(_ post: Post) async throws {}
    
    func delete(_ post: Post) async throws {}
    
    func join(_ post: Post) async throws {}
    
    var user = User.testUser
}
#endif


