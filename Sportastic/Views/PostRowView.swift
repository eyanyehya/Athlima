//
//  PostRowView.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/21/22.
//  View that shows specific info on each post

import SwiftUI
import MapKit

struct PostRowView: View {
    @State private var showConfirmationDialog = false
            
    // post row view model that allows for action like deleting post, joining post etc.
    @ObservedObject var viewModel: PostRowViewModel
    
    // filter making it easier to have specific behavior based on who and where the post is viewed
    var filter: PostsViewModel.Filter
        
    @EnvironmentObject private var factory: ViewModelFactory
    
    // current date to create count down
    @State var currentDate: Date = Date()
    
    // check to see if event can be joined
    @State var canJoinEvent: Bool?
    
    // region used to display post location
    @State private var region : MKCoordinateRegion = .init()
    
    // timer for countdown
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.currentDate = Date()
        })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // info on top of view showing author name, profile image and date post was made
            HStack {
                AuthorView(author: viewModel.author)
                Spacer()
                Text(viewModel.timePosted.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
            }
            .foregroundColor(.gray)
            
            // post title and description
            Text(viewModel.title)
                .font(.title3)
                .fontWeight(.semibold)
            Text(viewModel.description)
            
            HStack {
                VStack {
                    // map with a pin at the location of the post
                    Map(coordinateRegion: $region, annotationItems: [viewModel.location]) {
                        location in
                        MapMarker(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                    }
                    .onAppear {
                        // set region to be where post location is
                        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: viewModel.location.coordinate.latitude, longitude: viewModel.location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                    }
                    .frame(maxWidth: 200)
                    .frame(height: 300)
                    
                    // button that opens map in Apple Maps
                    Button(action: {
                        openMap(address: viewModel.location.name)
                    }, label: {
                        Text("Open in Maps")
                    })
                }
                VStack {
                    List (0..<6) { item in
                        switch item {
                        case 0:
                            Text("\(viewModel.sport.rawValue)")
                                .font(.callout)
                        case 1:
                            Text("\(viewModel.level.rawValue)")
                                .font(.callout)

                        case 2:
                            Text("\(viewModel.ageRequired.rawValue) year olds")
                                .font(.callout)

                        case 3:
                            Text("\(viewModel.playersMissing) spots left")
                                .font(.callout)

                        case 4:
                            Text("\(viewModel.time.formatted(date: .abbreviated, time: .omitted))")
                                .font(.callout)
                            
                        case 5:
                            Link(destination: URL(string: "tel:\(formatPhoneNumber(number: viewModel.author.phoneNumber))")!, label: { Text("\(viewModel.author.phoneNumber)").font(.callout).foregroundColor(.blue) })
                        default:
                            Text("None")
                        }
                    }
                    .listStyle(.plain)
                    .scrollDisabled(true)
                    
                    // if we are at the all posts tab or events attending tab or users events tab
                    if filter != .eventsCreated {
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            canJoinEvent = viewModel.joinEvent()
                        }, label: {
                            if filter == .eventsAttending {
                                Text("Attending Event")
                            }
                            // if the event does not need any more players
                            // and the user has not clicked on the join event button
                            // show that the event is full
                            else if viewModel.playersMissing == 0 && canJoinEvent == nil {
                                Text ("Event is Full")
                            }
                            // if the event does need more players
                            // and if the user has not yet clicked on the join event button
                            // canJoinEvent would still be nil so show Join Event writing
                            else if canJoinEvent == nil {
                                Text("Join Event")
                            }
                            // if the user clicked on the join event button and the output of viewModel.joinEvent is
                            // true then they have joined the event. If false then there was an error
                            else {
                                canJoinEvent! ? Text("Joined Event") : Text("Could not join event")
                            }
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                        .disabled(canJoinEvent != nil || viewModel.playersMissing == 0 || filter == .eventsAttending)
                    }
                    // if the user is looking at the events they have created
                    else {
                        NavigationLink(destination: UsersAttendingListView(postId: viewModel.id, users: []), label: {
                            Text("View Attendees")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .background(Color.accentColor)
                                .cornerRadius(10)
                        })
                    }

                }

            }
            
            HStack {
                CountDownView(timeLeft: timerFunction(from:viewModel.time))
                    .onAppear(perform: {
                        let _ = self.timer
                    })
                Spacer()
                if viewModel.canDeletePost {
                    Button(role: .destructive, action: {
                        showConfirmationDialog = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                    .labelStyle(.iconOnly)
                }
            }
            
            
        }
        .padding()
        
        .confirmationDialog("Are you sure you want to delete this post?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: { viewModel.deletePost() })
        }
        .alert("Error", error: $viewModel.error)
    }
    
    
    func timerFunction(from date: Date) -> String {
        let calender = Calendar(identifier: .gregorian)
        let timeValue = calender
            .dateComponents([.day, .hour, .minute, .second], from: currentDate, to: viewModel.time)
        return String(format: "%02d%02d%02d%02d",
                      timeValue.day!,
                      timeValue.hour!,
                      timeValue.minute!,
                      timeValue.second!)
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
    
    func openMap(address: String) {
        // remove all spaces from address and make them ,
        let address = address.replacingOccurrences(of: " ", with: ",")
        print("Address is \(address)")
        UIApplication.shared.open(URL(string: "http://maps.apple.com/?address=\(address)")! as URL)
    }

}

private extension PostRowView {
    struct FavoriteButton: View {
        let isFavorite: Bool
        let action: () -> Void
 
        var body: some View {
            Button(action: action) {
                if isFavorite {
                    Label("Remove from Favorites", systemImage: "heart.fill")
                } else {
                    Label("Add to Favorites", systemImage: "heart")
                }
            }
            .foregroundColor(isFavorite ? .red : .gray)
            .animation(.default, value: isFavorite)
        }
    }
    
    struct AuthorView: View {
        let author: User
     
        @EnvironmentObject private var factory: ViewModelFactory
     
        var body: some View {
            NavigationLink {
                PostsListView(viewModel: factory.makePostsViewModel(filter: .author(author)))
            } label: {
                HStack {
                    ProfileImage(url: author.imageURL)
                        .frame(width: 40, height: 40)
                    Text(author.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

// MARK: - PostImage

private extension PostRowView {
    struct PostImage: View {
        let url: URL
        
        var body: some View {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                Color.clear
            }
        }
    }
}

struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        PostRowView(viewModel: PostRowViewModel(post: Post.testPost, deleteAction: {}, joinEventAction: {}), filter: .all)
            .previewLayout(.sizeThatFits)
    }
}

