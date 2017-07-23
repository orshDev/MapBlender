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
    
    
    let place: GMSPlace
    var placeId : String  = ""    // 2
    init(place: GMSPlace) {
        self.place = place
        super.init()
        placeId = place.placeID
        position = place.coordinate
        groundAnchor = CGPoint(x: 0.5, y: 1)
         icon = UIImage(named: "marker.png")
//        guard  getIconByName(placeName: place.name) else {
//            icon = UIImage(named: "marker.png")
//            return
//        }
          //   appearAnimation = KGMSMarkerAnimationPop
        // = GMSMarkerAnimation()

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
       
        // Initialize an array for your pictures
        guard let dbRef = self.database?.reference().child("brand_icon/\(placeName)") else {
            print("no exsit DB location")
            return false
        }
        let fileData = NSData() // get data...
        guard let storageRef = storage?.reference().child("brand_icon/\(placeName)")
            else {
            print("defualt icon")
            icon = UIImage(named: "marker.png")
            return false
            }
        storageRef.put(fileData as Data).observe(.success) { (snapshot) in
            // When the image has successfully uploaded, we get it's download URL
            if ((snapshot.error) != nil){
                print("not exsit storage ref")
                return
            }
            let downloadURL = snapshot.metadata?.downloadURL()?.absoluteString
            // Write the download URL to the Realtime Database
            
            dbRef.setValue(downloadURL)
            
        }
         //   let dbRef = database.reference().child("myFiles")
            dbRef.observe(.childAdded, with: { (snapshot) in
                // Get download URL from snapshot
                if (!snapshot.exists()){
                print("not exsit db ref")
                    return 
                }
                
                let downloadURL = snapshot.value as! String
                // Create a storage reference from the URL
                let storageRefpic = self.storage?.reference(forURL: downloadURL)
                // Download the data, assuming a max size of 1MB (you can change this as necessary)
                storageRefpic?.data(withMaxSize: 1 * 256 * 256) { (data, error) -> Void in
                    // Create a UIImage, add it to the array
                 //   let pic = UIImage(data: data!)
                   // picArray.append(pic!)
                    self.icon = UIImage(data:data!)
                }
            })
         return true
        }
   
    }
    

