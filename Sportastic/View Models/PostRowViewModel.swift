//
//  PostRowViewModel.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/21/22.
//  Post row view model that allows users to interact with posts, joining posts, deleting, etc.

import Foundation
import SwiftUI
import MapKit

@MainActor
@dynamicMemberLookup
class PostRowViewModel: ObservableObject, StateManager {
    typealias Action = () async throws -> Void
 
    // post being looked at
    @Published var post: Post
    @Published var error: Error?
    
 
    // actions that can be performed on posts
    private let deleteAction: Action?
    private let joinEventAction: Action?
    
    // check to see if user can delete post
    var canDeletePost: Bool { deleteAction != nil }
    
    // function that allows user to delete a post
    func deletePost() {
        // if delete action is nil then cannot delete otherwise withStateManagingTask(perform: deleteAction)
        guard let deleteAction = deleteAction else {
            preconditionFailure("Cannot delete post: no delete action provided")
        }
        
        // perform action
        withStateManagingTask(perform: deleteAction)
    }
    
    // function that allows user to join an event
    func joinEvent() -> Bool {
        // if join action is nil then cannot join otherwise withStateManagingTask(perform: joinAction)
        guard let joinEventAction = joinEventAction else {
            preconditionFailure("Cannot join event: no join event action provided")
        }
        
        // perform action
        withStateManagingTask(perform: joinEventAction)
        
        // if no error occurs it means that error is still nil so return true meaning that the user joined the event successfully
        if error == nil {
            return true
        }
        // return false if the error is not nil as that means that the user could not join the event for some error
        return false
    }
 
    init(post: Post, deleteAction: Action?, joinEventAction: Action?) {
        self.post = post
        self.deleteAction = deleteAction
        self.joinEventAction = joinEventAction
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<Post, T>) -> T {
        post[keyPath: keyPath]
    }
}
