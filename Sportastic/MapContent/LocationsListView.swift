//
//  LocationsListView.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/19/22.
//

import SwiftUI
import MapKit

struct LocationsListView: View {
    @EnvironmentObject var searchViewModel: SearchViewModel
    @Binding var selectedLocation: LocationInfo
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            List(searchViewModel.landmarks) { landmark in
                HStack {
                    VStack(alignment: .leading) {
                        Text(landmark.name)
                        Text(landmark.title)
                            .opacity(0.5)
                    }
                    Spacer()
                    if searchViewModel.Chosenlandmark == landmark {
                        Image(systemName: "checkmark")
                    }
                }.contentShape(Rectangle())
                    .onTapGesture {
                        searchViewModel.Chosenlandmark = landmark
                        selectedLocation = LocationInfo(name: landmark.title, countryCode: landmark.countryCode, coordinate: Coordinate(latitude: landmark.coordinate.latitude, longitude: landmark.coordinate.longitude))
                        searchViewModel.region = MKCoordinateRegion.regionFromLandmark(landmark)
                    }
            }
            
            Map(coordinateRegion: $searchViewModel.region, showsUserLocation: true, annotationItems: searchViewModel.landmarks) { landmark in
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: landmark.coordinate.latitude, longitude: landmark.coordinate.longitude))
            }
            .padding()
            .cornerRadius(10)
            
            if searchViewModel.Chosenlandmark != nil {
                Button (action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Select Location")
                }
                .buttonStyle(.primary)
                .padding()
            }
        }
    }
}

struct LocationsListView_Previews: PreviewProvider {
    @State static var selectedLocation = LocationInfo(name: "place", countryCode: "code", coordinate: Coordinate(latitude: 123, longitude: 456))
    static var previews: some View {
        LocationsListView(selectedLocation: $selectedLocation)
    }
}
