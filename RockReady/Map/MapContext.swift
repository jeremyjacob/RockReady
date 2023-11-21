//
//  MapModel.swift
//  RockReady
//
//  Created by Jeremy Jacob on 6/19/23.
//

import Foundation
import SwiftUI
import MapKit
//import GameKit

@MainActor
final class MapContext: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var mapType: MKMapType = .standard
    @Published var hasLocation: Bool = false
    @Published var mapView: MKMapView = MKMapView(frame: .zero)
    @Published var userTrackingMode: MKUserTrackingMode = .none
//    @Published var annotations: [CustomAnnotation] = []
//    @Published var quadtree: GKQuadtree = GKQuadtree.init(boundingQuad: GKQuad.init(quadMin: vector_float2(-180, -90), quadMax: vector_float2(180, 90))
//, minimumCellSize: 0.1)
    
    private let locationManager = CLLocationManager()
    private var setInitialLocation = false
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
            self.hasLocation = status == .authorizedAlways || status == .authorizedWhenInUse
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
            if setInitialLocation == false {
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                self.mapView.setRegion(region, animated: false)
                setInitialLocation = true
                
            }
        }
    }
    
}

