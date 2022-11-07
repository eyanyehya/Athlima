//
//  StateManager.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/18/22.
//  Handles actions that change states 

import Foundation
import SwiftUI

@MainActor
protocol StateManager: AnyObject {
    var error: Error? { get set }
    var isWorking: Bool { get set }
}

extension StateManager {
    var isWorking: Bool {
        get { false }
        set {}
    }
}

extension StateManager {
    typealias Action = () async throws -> Void
    
    nonisolated func withStateManagingTask(perform action: @escaping Action) {
        Task {
            await withStateManagement(perform: action)
        }
    }
    
    // performs actions eg. sign in and changes isWorking boolean based on status of the action
    // if action throws an error then print the error and set isWorking to false
    private func withStateManagement(perform action: @escaping Action) async {
        isWorking = true
        do {
            try await action()
        } catch {
            print("[\(Self.self)] Error: \(error)")
            self.error = error
        }
        isWorking = false
    }
}
