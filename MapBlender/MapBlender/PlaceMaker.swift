//
//  PlaceMaker.swift
//  MapBlender
//
//  Created by MacOS on 7/8/17.
//  Copyright © 2017 MacOS. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class PlaceMaker: GMSMarker {
    
    
    let place: GMSPlace
    
    // 2
    init(place: GMSPlace) {
        self.place = place
        super.init()
        
        position = place.coordinate
        icon = UIImage(named: place.types.first!)
        groundAnchor = CGPoint(x: 0.5, y: 1)
        // = GMSMarkerAnimation()

    }
}
