//
//  CustomAnnotation.swift
//  RockReady
//
//  Created by Jeremy Jacob on 6/22/23.
//

import Foundation
import MapKit
import UIKit

class CustomAnnotation: NSObject, MKAnnotation, Identifiable {
    var id = UUID()
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var areaId: Int
    var parentId: Int?

    init(title: String?,
         subtitle: String?,
         coordinate: CLLocationCoordinate2D,
         areaId: Int,
         parentId: Int?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.areaId = areaId
        self.parentId = parentId
    }
    
    static func == (lhs: CustomAnnotation, rhs: CustomAnnotation) -> Bool {
        return lhs.id == rhs.id
    }
}

//class CustomClusterAnnotationView: MKAnnotationView {
//    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
//        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//        displayPriority = .defaultHigh
//        collisionMode = .circle
//        centerOffset = CGPoint(x: 0, y: -10) // Adjust the center offset as needed
//        
//        // Customize the appearance of the cluster
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
//        label.textAlignment = .center
//        label.font = UIFont.boldSystemFont(ofSize: 13)
//        label.textColor = .white
//        label.adjustsFontSizeToFitWidth = true
//        label.clipsToBounds = true
//        label.layer.cornerRadius = label.frame.width * 0.5
//        label.layer.backgroundColor = UIColor.systemBlue.cgColor
//        addSubview(label)
//
//        if let cluster = annotation as? MKClusterAnnotation {
//            label.text = "\(cluster.memberAnnotations.count)"
//        } else {
//            label.text = "?"
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
