//
//  FormViewModel.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/18/22.
//  View model that can be used for multiple forms (sign in and create account forms)
//  Given the different values perform an action (sign in interacting with firebase for eg.) when submit is called

import Foundation
import SwiftUI

@MainActor
@dynamicMemberLookup
class FormViewModel<Value>: ObservableObject, StateManager {
    
    // typealias to make it code more readable
    typealias Action = (Value) async throws -> Void
    
    // action that is performed by the view model
    private let action: Action
    
    // value will be tuples so (email, password) if its SignInViewModel and (name, email, password) if its CreateAccountViewModel
    @Published var value: Value
    @Published var error: Error?
    @Published var isWorking = false
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
        get { value[keyPath: keyPath] }
        set { value[keyPath: keyPath] = newValue }
    }

    
    init(initialValue: Value, action: @escaping Action) {
        self.value = initialValue
        self.action = action
    }
    
    nonisolated func submit() {
        withStateManagingTask { [self] in
            try await action(value)
        }
    }
}
