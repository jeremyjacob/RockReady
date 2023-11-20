//
//  MapModel.swift
//  RockReady
//
//  Created by Jeremy Jacob on 6/19/23.
//

import Foundation
import SwiftUI
import MapKit

final class MapContext: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var mapType: MKMapType = .standard
    @Published var hasLocation: Bool = false
    @Published var mapView: MKMapView?
    @Published var userTrackingMode: MKUserTrackingMode = .none
    
    private let locationManager = CLLocationManager()
    
    override init() {
        let status = locationManager.authorizationStatus
        self.hasLocation = status == .authorizedAlways || status == .authorizedWhenInUse
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        self.hasLocation = status == .authorizedAlways || status == .authorizedWhenInUse
    }
    
//    didUpdateLocations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("didUpdateLocations: \(location)")
        self.mapView?.setCenter(location.coordinate, animated: true)
    }
    
}

