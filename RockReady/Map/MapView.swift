//
//  MapView.swift
//  RockReady
//
//  Created by Jeremy Jacob on 6/19/23.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    @EnvironmentObject private var mapContext: MapContext
    @EnvironmentObject private var packageStore: MPPackageStore;
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        mapContext.mapView.showsUserLocation = true
        mapContext.mapView.preferredConfiguration = MKStandardMapConfiguration.init()
        mapContext.mapView.isPitchEnabled = true
        mapContext.mapView.showsScale = true
        mapContext.mapView.layoutMargins = UIEdgeInsets(top: 106, left: 0, bottom: 0, right: 5) // TODO showCompass = false and use a seperate compass
        mapContext.mapView.delegate = context.coordinator
        
        
        // Reset user tracking mode when map is panned
        let panGestureRecognizer = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.didPanMap(_:)))
        panGestureRecognizer.delegate = context.coordinator
        mapContext.mapView.addGestureRecognizer(panGestureRecognizer)
        
        let rotateGestureRecognizer = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.didRotateMap(_:)))
        rotateGestureRecognizer.delegate = context.coordinator
        mapContext.mapView.addGestureRecognizer(rotateGestureRecognizer)
        
        
        return mapContext.mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        updateMapUserTrackingMode(view)
        updateMapType(view)
//        updateMapAnnotations(view)
    }
    
    private func updateMapType(_ view: MKMapView) {
        view.mapType = mapContext.mapType
    }
    
    private func updateMapUserTrackingMode(_ view: MKMapView) {
        view.setUserTrackingMode(mapContext.userTrackingMode, animated: true)
    }
    
//    private func updateMapAnnotations(_ view: MKMapView) {
//        view.removeAnnotations(view.annotations)
//        view.addAnnotations(mapContext.annotations)
//    }
    
    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        @objc func didPanMap(_ sender: UIPanGestureRecognizer) {
            if sender.state == .began && sender.numberOfTouches == 1 {
                parent.mapContext.userTrackingMode = .none
            }
        }
        
        @objc func didRotateMap(_ sender: UIRotationGestureRecognizer) {
            if sender.state == .began && parent.mapContext.userTrackingMode == .followWithHeading {
                parent.mapContext.userTrackingMode = .follow
            }
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            if annotation is MKClusterAnnotation {
                let identifier = ClusteredAnnotationView.reuseIdentifier
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? ClusteredAnnotationView
                if annotationView == nil {
                    annotationView = ClusteredAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                } else {
                    annotationView?.annotation = annotation
                }
                return annotationView
            } else {
                let identifier = SingleAnnotationView.reuseIdentifier
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? SingleAnnotationView
                if annotationView == nil {
                    annotationView = SingleAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                } else {
                    annotationView?.annotation = annotation
                }
                return annotationView
            }
        }
    }
}

func convertEpsg3857ToEpsg4326(x: Double, y: Double) -> (latitude: Double, longitude: Double) {
    let originShift = 2 * Double.pi * 6378137 / 2.0
    
    let lon = (x / originShift) * 180.0
    let lat = (y / originShift) * 180.0
    
    let latRadian = lat * Double.pi / 180.0
    var latInDegrees = atan(exp(latRadian)) * 2.0 - Double.pi / 2.0
    latInDegrees = latInDegrees * 180.0 / Double.pi
    
    return (latitude: latInDegrees, longitude: lon)
}
