//
//  ContentView.swift
//  RockReady
//
//  Created by Jeremy Jacob on 6/19/23.
//

import SwiftUI
import MapKit

final class LocationDataMapClusterView: MKAnnotationView {
    
    // MARK: Initialization
    private let countLabel = UILabel()
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let annotation = annotation as? MKClusterAnnotation else {
                assertionFailure("Using LocationDataMapClusterView with wrong annotation type")
                return
            }
            
            countLabel.text = annotation.memberAnnotations.count < 100 ? "\(annotation.memberAnnotations.count)" : "99+"
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        displayPriority = .defaultHigh
        collisionMode = .circle
        
        frame = CGRect(x: 0, y: 0, width: 40, height: 50)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = backgroundView.frame.size.width / 2
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.borderColor = UIColor.systemBlue.cgColor
        backgroundView.clipsToBounds = true
        addSubview(backgroundView)
        
        countLabel.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        countLabel.textAlignment = .center
        countLabel.textColor = .systemBlue
        countLabel.font = UIFont.boldSystemFont(ofSize: 16)
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 0.5
        addSubview(countLabel)
    }
}

struct ContentView: View {
    @EnvironmentObject private var packageStore: MPPackageStore;
    @EnvironmentObject private var mapContext: MapContext;
    @Namespace private var locationScope;
    
    let size: CGFloat = 42;
    var body: some View {
        ZStack {
            MapView()
                .edgesIgnoringSafeArea(.all)
            //            Map {
            //                ForEach(packageStore.packages.sorted(by: {$0.key < $1.key}), id: \.key) { id, package in
            //                    let limitedAreas = package.data.areas.prefix(200)
            //                    ForEach(limitedAreas, id: \.id) { area in
            //                        let coords = convertEpsg3857ToEpsg4326(x: Double(area.x), y: Double(area.y))
            //                        let coordinate = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude);
            //
            //                    }
            //                }
            //            }
            VStack {
                MapButtonsView().environmentObject(mapContext)
                Spacer()
            }.padding(10).environmentObject(packageStore)
            //            VStack {
            //                ForEach(packageStore.packages.sorted(by: {$0.key < $1.key}), id: \.key) { id, package in
            //                    Text(String(package.id))
            //                }
            //            }
            //            .background(.white)
            //            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
        }.preferredColorScheme(mapContext.mapType == .hybridFlyover ? .dark : nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let packageStore = MPPackageStore()
        ContentView().environmentObject(packageStore)
    }
}
