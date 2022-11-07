//
//  LocalSearchService.swift
//  Places
//
//  Created by Mohammad Azam on 7/29/22.
//

import Foundation
import MapKit
import Combine

class SearchViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion = MKCoordinateRegion.defaultRegion()
    var cancellables = Set<AnyCancellable>()
    @Published var landmarks: [Landmark] = []
    @Published var Chosenlandmark: Landmark?
        
    func search(query: String) {
//        print("In search function")
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            // if response is not nil
            if let response = response {
                let mapItems = response.mapItems
//                print("MapItems is \(mapItems.forEach({ $0.name ?? "None" }))")
                self.landmarks = mapItems.map {
                    Landmark(placemark: $0.placemark)
                }
                
            }
        }
    }
}
