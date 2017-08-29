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
import Firebase
import FirebaseStorage

public class PlaceMarker: GMSMarker {
    
    // Firebase services
    var database: FIRDatabase!
    var storage: FIRStorage!
    var picArray = [UIImage]()
    var downloadURL = ""
    var iconpic : UIImage?
    var iconpicView : UIImageView?
    let place: GMSPlace
    var markerView = UIImageView()
    var placeId : String  = ""    // 2
    init(place: GMSPlace) {
        self.place = place
        super.init()
        placeId = place.placeID
        iconpic = self.icon
        position = place.coordinate
       
        groundAnchor = CGPoint(x: 0.5, y: 1)
        guard  getIconByName(placeName: place.name) else {
            return
        }
    }
    
   public func getPlaceID ()->String
    {
        
        return placeId
    }
    
    public func getIconByName(placeName:String)->Bool
        
    {
        // Initialize Database, Auth, Storage
        database = FIRDatabase.database()
        storage = FIRStorage.storage()
        
        // Create a reference to the file you want to download
        guard let islandRef = storage?.reference().child("brand_icon/\(placeName)/\(placeName).png") else {
            print("wrong path")
            return false
        }
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        islandRef.data(withMaxSize: 1 * 256 * 256) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                
                let value = self.place.value(forKey: "isAccessibilityElement") as! Bool
               //  print("get open ans: \(value)")
                if (value){
                
                    self.icon = UIImage(data:data!)?.roundedImageWithBorder(width: 4, color: UIColor.green)
                }
                else{
                    self.icon = UIImage(data:data!)?.roundedImageWithBorder(width: 4, color: UIColor.red)
                }
            }
        }
    return true
    }
}

