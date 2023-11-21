//
//  RockReadyApp.swift
//  RockReady. Where the rock are.
//
//  Created by Jeremy Jacob on 6/19/23.
//

import SwiftUI
import MapKit
//import GameKit

@main
struct RockReadyApp: App {
    @StateObject private var packageStore = MPPackageStore()
    @StateObject private var mapContext = MapContext()
    
    var body: some Scene {
        WindowGroup {
            ContentView().task {
                do {
                    try await packageStore.load()
                    print("Successfully loaded package store")
                    try await packageStore.downloadPackage(id: 105708959)
                    print("Succesfully downloaded a package")
                    
                    for (_, package) in packageStore.packages {
                        for area in package.data.areas {
//                            let point = MKPointAnnotation()
                            let coords = convertEpsg3857ToEpsg4326(x: Double(area.x), y: Double(area.y))
                            let coordinate = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude);
                            let point = CustomAnnotation(title: area.title, subtitle: nil, coordinate: coordinate, areaId: area.id, parentId: area.parentId)
                            point.title = area.title
                            point.coordinate = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude)
                            mapContext.mapView.addAnnotation(point)
                        }
                    }
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
            .environmentObject(packageStore)
             .environmentObject(mapContext)
        }
    }
}
