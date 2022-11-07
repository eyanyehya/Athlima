//
//  ContentView.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/18/22.
//  Main tab view where user can view the available events, their own created events, events they are attending and their profile

import SwiftUI

struct MainTabView: View {
    // object that creates view models for different uses
    @EnvironmentObject private var factory: ViewModelFactory

    var body: some View {
        TabView {
            // tab showing other peoples active and valid events
            NavigationView {
                PostsListView(viewModel: factory.makePostsViewModel())
            }
            .tabItem {
                Label("Activities", systemImage: "sportscourt.circle.fill")
            }
            
            // tab showing current users events
            NavigationView {
                PostsListView(viewModel: factory.makePostsViewModel(filter: .eventsCreated))
            }
            .tabItem {
                Label("My Events", systemImage: "flag.2.crossed.circle.fill")
            }
            
            // tab showing the events the current user has joined
            NavigationView {
                PostsListView(viewModel: factory.makePostsViewModel(filter: .eventsAttending))
            }
            .tabItem {
                Label("Events Attending", systemImage: "baseball.diamond.bases")
            }
            
            // tab showing users profile
            ProfileView(viewModel: factory.makeProfileViewModel())
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView()
//            .environmentObject(ViewModelFactory.preview)
//    }
//}
