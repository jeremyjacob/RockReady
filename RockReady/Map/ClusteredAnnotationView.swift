//
//  ClusteredAnnotationView.swift
//  RockReady
//
//  Created by Jeremy Jacob on 6/22/23.
//

import Foundation
import MapKit
import SwiftUI

class ClusteredAnnotationView: MKMarkerAnnotationView {
    static let reuseIdentifier = "ClusteredAnnotationView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        //        clusteringIdentifier = "clusterAnnotation"
        
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10) // Offset center point to animate better with marker annotations
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            if let annotation = annotation as? CustomAnnotation {
                clusteringIdentifier = String(annotation.parentId ?? annotation.areaId)
                self.displayPriority = annotation.parentId != nil ? .defaultLow : .defaultHigh
//                clusteringIdentifier = "routeAnnotation"
            }
        }
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        if let cluster = annotation as? MKClusterAnnotation {
            let totalAreas = cluster.memberAnnotations.count
        }
    }
    
//    override func prepareForDisplay() {
//        super.prepareForDisplay()
//        if let cluster = annotation as? MKClusterAnnotation {
////            collisionMode = .circle
////            canShowCallout = true
////            clusteringIdentifier = "clusterAnnotation"
////            displayPriority = .required
////            glyphText = String(cluster.memberAnnotations.count)
//        }
//    }
}
