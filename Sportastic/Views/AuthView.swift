//
//  AuthView.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/18/22.
//
//  View that checks if the user is signed in. If they are then it takes them to the main tab view where they can interact with the app
//  if the user is not signed in it shows them the sign in / create account views so that they can make an account or sign in

import SwiftUI
import iPhoneNumberField

struct AuthView: View {
    // auth view model
    @StateObject var viewModel = AuthViewModel()
    
    var body: some View {
        // if the user is signed in
        if let viewModelFactory = viewModel.makeViewModelFactory() {
            // enter MainTabView with the viewModelFactory as we'll use it to create new view models 
            MainTabView()
                .environmentObject(viewModelFactory)
        }
        // if user is nil / the user is not signed in
        else {
            NavigationView {
                // display a sign in form using the SignInViewModel that the AuthViewModel() creates
                SignInForm(viewModel: viewModel.makeSignInViewModel()) {
                    // footer
                    // display a create account form using the CreateAccountViewModel that the AuthViewModel() creates
                    NavigationLink("Create Account", destination: CreateAccountForm(viewModel: viewModel.makeCreateAccountViewModel()))
                }
            }
        }
    }
}

private extension AuthView {
    // create account form where user creates an account using different fields
    struct CreateAccountForm: View {
        @StateObject var viewModel: AuthViewModel.CreateAccountViewModel
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            // form where user input their info to create an account
            Form {
                // users name
                TextField("Name", text: $viewModel.name)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                
                // users birthday (used to calculate age)
                DatePicker("Birthday", selection: $viewModel.birthday, in: ...Date(), displayedComponents: .date)

                // users phone number
                iPhoneNumberField("Phone Number", text: $viewModel.phoneNumber)

                // users email
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                
                // users password
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.newPassword)
            } footer: {
                Button("Create Account", action: {
                    viewModel.submit()
                })
                .buttonStyle(.primary)
                Button("Sign In", action: dismiss.callAsFunction)
                    .padding()
            }
            .alert("Cannot Create Account", error: $viewModel.error)
            .onSubmit(viewModel.submit)
            .disabled(viewModel.isWorking)
        }
    }
    
    // sign in form where user can enter their email and password and sign in
    struct SignInForm<Footer: View>: View {
        @StateObject var viewModel: AuthViewModel.SignInViewModel
        @ViewBuilder let footer: () -> Footer
        
        var body: some View {
            Form {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
            } footer: {
                Button("Sign In", action: viewModel.submit)
                    .buttonStyle(.primary)
                footer()
                    .padding()
            }
            .alert("Cannot Sign In", error: $viewModel.error)
            .onSubmit(viewModel.submit)
            .disabled(viewModel.isWorking)
        }
    }
    
    // form view blueprint that both sign in and create account form follow
    struct Form<Content: View, Footer: View>: View {
        // content of the view (eg. email and password fields for sign in form)
        @ViewBuilder let content: () -> Content
        
        // footer of view usually the submit button
        @ViewBuilder let footer: () -> Footer
        
        var body: some View {
            VStack {
                Text("Sportastic ⚽️🏀🏈")
                    .font(.title.bold())
                content()
                    .padding()
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(10)
                footer()
            }
            .navigationBarHidden(true)
            .padding()
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
