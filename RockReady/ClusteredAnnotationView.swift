//
//  ClusteredAnnotation.swift
//  RockReady
//
//  Created by Jeremy Jacob on 6/22/23.
//

import Foundation
import MapKit

class ClusteredAnnotationView: MKMarkerAnnotationView {
    static let reuseIdentifier = "ClusteredAnnotationView"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        // This clusteringIdentifier must be set for automatic clustering
        clusteringIdentifier = "clusterAnnotation"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()

        if let cluster = annotation as? MKClusterAnnotation {
            collisionMode = .circle
            canShowCallout = true
            markerTintColor = .red
            glyphText = String(cluster.memberAnnotations.count)
        } else {
            canShowCallout = true
            markerTintColor = .red
            glyphImage = UIImage(systemName: "figure.climbing")
        }
    }
}
