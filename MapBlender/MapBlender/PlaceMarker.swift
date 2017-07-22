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

public class PlaceMarker: GMSMarker {
    
    
    let place: GMSPlace
    var placeId : String  = ""    // 2
    init(place: GMSPlace) {
        self.place = place
        super.init()
        placeId = place.placeID
        position = place.coordinate
        icon = UIImage(named: "marker.png")
        groundAnchor = CGPoint(x: 0.5, y: 1)
     //   appearAnimation = KGMSMarkerAnimationPop
        // = GMSMarkerAnimation()

    }
    
   public func getPlaceID ()->String
    {
        
        return placeId
    }
    
}
