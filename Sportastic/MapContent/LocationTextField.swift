//
//  LocationTextField.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/19/22.
//

import SwiftUI
import MapKit

struct LocationTextField: View {
    @EnvironmentObject var localSearchService: SearchViewModel
    @State private var search: String = ""
    @Binding var selectedLocation: LocationInfo
    @State var searchedForName: Bool = false
    
    var body: some View {
        VStack {
            TextField("Enter Location", text: $search)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
//                    print("Submitted search with query being \(search)")
                    localSearchService.search(query: search)
                    searchedForName = true
                }.padding()
            
            // if the user searched for an input and the output is no locations
            if localSearchService.landmarks.isEmpty && searchedForName {
                EmptyView()
            } else {
                LocationsListView(selectedLocation: $selectedLocation)
            }
            Spacer()
            
//
            Spacer()
        }
    }
}

struct LocationTextField_Previews: PreviewProvider {
    @State static var selectedLocation = LocationInfo(name: "place", countryCode: "code", coordinate: Coordinate(latitude: 123, longitude: 456))
    static var previews: some View {
        LocationTextField(selectedLocation: $selectedLocation)
            .environmentObject(SearchViewModel())
    }
}
