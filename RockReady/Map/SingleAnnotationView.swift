//
//  SingleAnnotationView.swift
//  RockReady
//
//  Created by Jeremy Jacob on 6/23/23.
//

import Foundation
import MapKit

class SingleAnnotationView: MKMarkerAnnotationView {
    static let reuseIdentifier = "SingleAnnotationView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//        clusteringIdentifier = "clusterAnnotation"
        if let annotation = annotation as? CustomAnnotation {
            clusteringIdentifier = String(annotation.parentId ?? annotation.areaId)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            clusteringIdentifier = "routeAnnotation"
            if let annotation = annotation as? CustomAnnotation {
//                clusteringIdentifier = String(annotation.parentId ?? annotation.areaId)
            }
        }
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        canShowCallout = true
        displayPriority = .required
        clusteringIdentifier = "clusterAnnotation"
        glyphImage = UIImage(systemName: "figure.climbing")
    }
}
