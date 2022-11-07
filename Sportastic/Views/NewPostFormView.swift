//
//  NewPostFormView.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/19/22.
//

import SwiftUI
import iPhoneNumberField

struct NewPostFormView: View {
    
    @StateObject var viewModel: FormViewModel<Post>
    @StateObject var searchViewModel = SearchViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    @State var selectedSport = Sport.none
    
    var body: some View {
        NavigationView {
            Form {
                Section("Activity Information") {
                    Picker("Sport", selection: $viewModel.sport) {
                        ForEach (Sport.allCases, id: \.self) { sport in
                            Text(sport.rawValue)
                                .tag(sport)
                        }
                    }
                    .padding()

                    TextField("Title", text: $viewModel.title)
                        .padding()

                    TextField("Description", text: $viewModel.description, axis: .vertical)
                        .multilineTextAlignment(.leading)
                        .padding()
                    
                    DatePicker("Date", selection: $viewModel.time, in: Date()...)
                        .padding()

                }
                
                Section("Location") {
                    NavigationLink(destination: LocationTextField(selectedLocation: $viewModel.location).environmentObject(searchViewModel), label: {
                        searchViewModel.Chosenlandmark != nil ? Text(searchViewModel.Chosenlandmark!.title) : Text("Enter location")
                    } )
                    .padding()
                }
                
                Section("Extra Information") {
                    
                    Picker("Level", selection: $viewModel.level) {
                        ForEach (Level.allCases, id: \.self) { level in
                            Text(level.rawValue)
                                .tag(level)
                        }
                    }
                    .padding()
                    
                    
                    Picker("Age Required", selection: $viewModel.ageRequired) {
                        ForEach (Age.allCases, id: \.self) { age in
                            Text(age.rawValue)
                                .tag(age)
                        }
                    }
                    .padding()
                    
                    Stepper("Players Needed: \(viewModel.playersMissing) ", value: $viewModel.playersMissing, in: 0...1000)
                        .padding()
                }
                
                Button(action: viewModel.submit) {
                    if viewModel.isWorking {
                        ProgressView()
                    } else {
                        Text("Create Post")
                    }
                }
//                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(10)
                .disabled(viewModel.sport.rawValue == "" || viewModel.title == "" || viewModel.playersMissing == 0 || viewModel.location.name.isEmpty)
                
//                .font(.headline)
//                .frame(maxWidth: .infinity)
//                .foregroundColor(.white)
//                .padding()
//                .listRowBackground(Color.accentColor)
//                .disabled(viewModel.sport.rawValue == "none" || viewModel.title == "" || viewModel.playersMissing == 0 || viewModel.location.name.isEmpty)
            }
            .onSubmit(viewModel.submit)
            .navigationTitle("Create Activity")
        }
        .alert("Cannot Create Post", error: $viewModel.error)
        .disabled(viewModel.isWorking)
        // This modifier calls the dismiss action when the view model’s isWorking property is changed to false.
        .onChange(of: viewModel.isWorking) { isWorking in
            guard !isWorking else { return }
            dismiss()
        }
    }
}

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostFormView(viewModel: FormViewModel(initialValue: Post.testPost, action: { _ in }))
    }
}
