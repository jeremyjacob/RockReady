//
//  MapButtons.swift
//  RockReady
//
//  Created by Jeremy Jacob on 6/19/23.
//

import Foundation
import SwiftUI

// mapbuttons UI component

struct MapButtons: View {
    @EnvironmentObject private var mapSettings: MapContext
    
    let size: CGFloat = 44;

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 0) {
                if mapSettings.mapType == .standard {
                    Button(action: {
                        mapSettings.mapType = .hybridFlyover
                    }) {
                        Image(systemName: "map.fill")
                            .frame(width: size, height: size)
                    }
                } else {
                    Button(action: {
                        mapSettings.mapType = .standard
                    }) {
                        Image(systemName: "globe.americas.fill")
                            .frame(width: size, height: size)
                    }
                }
                if mapSettings.hasLocation {
                    Divider().frame(width: size)
                    if mapSettings.userTrackingMode == .follow {
                        Button(action: {
    //
                        }) {
                            Image(systemName: "location.fill")
                                .frame(width: size, height: size)
                            
                        }
                    } else {
                        Button(action: {
                            mapSettings.userTrackingMode = .follow
                        }) {
                            Image(systemName: "location")
                                .frame(width: size, height: size)
                            
                        }
                    }
                }
            }
            .background(.ultraThickMaterial)
            .foregroundColor(Color(UIColor.label.withAlphaComponent(0.56)))
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
            .shadow(color: Color(UIColor.black.withAlphaComponent(0.2)), radius: 6)
        }
    }
}

