//
//  Landmark.swift
//  Places
//
//  Created by Mohammad Azam on 7/29/22.
//  Model representing a landmark which will be used to display a pin on the location of the event 

import Foundation

import MapKit

struct Landmark: Identifiable, Hashable {
    
    let placemark: MKPlacemark
    
    let id = UUID()
    
    var name: String {
        self.placemark.name ?? ""
    }
    
    var title: String {
        self.placemark.title ?? ""
    }
    
    var coordinate: CLLocationCoordinate2D {
        self.placemark.coordinate
    }
    
    var countryCode: String {
        self.placemark.countryCode ?? ""
    }
}
