//
//  AuthViewModel.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/18/22.
//  View Model that creates view models for sign in, creating account and a special viewmodel "ViewModelFactory" that helps create other view models for different views in the app

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class AuthViewModel: ObservableObject {
    // user object which is the same as the user object in auth service
    @Published var user: User?

    // auth service that allows us to create user account on firebase, sign in the user and sign out
    private let authService = AuthService()
 
    // This copies the user property from the AuthService to the AuthViewModel, and keeps the property up to date when it changes.
    init() {
        authService.$user.assign(to: &$user)
    }
    
    // function that creates a sign in view model
    func makeSignInViewModel() -> SignInViewModel {
        return SignInViewModel(action: authService.signIn(email:password:))
    }
     
    // function that creates a create account view model
    func makeCreateAccountViewModel() -> CreateAccountViewModel {
        return CreateAccountViewModel(action: authService.createAccount(name:email:password:birthday:phoneNumber:))
    }
    
    // function that creates a view model factory
    func makeViewModelFactory() -> ViewModelFactory? {
        // if user is nil then return nil otherwise return ViewModelFactory()
        // guard makes sure that the statement its guarding is true / non-nil and if it is then the else will NOT be executed
        // if the statement is false / nil then the else WILL be executed
        guard let user = user else {
            return nil
        }
        return ViewModelFactory(user: user, authService: authService)
    }
}

extension AuthViewModel {
    class SignInViewModel: FormViewModel<(email: String, password: String)> {
        // creates a new FormViewModel
        // so when new SignInViewModel object is created its like you are creating a new FormViewModel
        convenience init(action: @escaping Action) {
            self.init(initialValue: (email: "", password: ""), action: action)
        }
    }
 
    class CreateAccountViewModel: FormViewModel<(name: String, email: String, password: String, birthday: Date, phoneNumber: String)> {
        // creates a new FormViewModel
        convenience init(action: @escaping Action) {
            self.init(initialValue: (name: "", email: "", password: "", birthday: Date(), phoneNumber: ""), action: action)
        }
    }
}
