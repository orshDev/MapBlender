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
      //   icon = UIImage(named: "marker.png")
        guard  getIconByName(placeName: place.name) else {
            //icon = UIImage(named: "marker.png")
            return
        }
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
//        guard let dbRef = self.database?.reference().child("brand_icon") else {
//            print("no exsit DB location")
//            return false
//        }
        
//        let fileData = NSData() // get data...
//        guard let storageRef = storage?.reference().child("brand_icon/\(placeName)/")
//            
//            else {
//            print("defualt icon")
//            icon = UIImage(named: "marker.png")
//            return false
//            }
//        print("rep \(storageRef)")
//        storageRef.(fileData as Data).observe(.success) { (snapshot) in
//            // When the image has successfully uploaded, we get it's download URL
//            print(snapshot)
//            if ((snapshot.error) != nil){
//                print("not exsit storage ref")
//                return
//            }
//            if (!(snapshot.accessibilityActivate())){
//                print("not accses storage ref")
//                return
//            }
//
//             self.downloadURL = (snapshot.metadata?.downloadURL()?.absoluteString)!
//            // Write the download URL to the Realtime Database
//            print("downloadURL: \(self.downloadURL)")
//            
//           // print("downloadURL\(downloadURL)")
//            let storageRefpic = self.storage?.reference(forURL: self.downloadURL)
//            // Download the data, assuming a max size of 1MB (you can change this as necessary)
//            storageRefpic?.data(withMaxSize: 1 * 256 * 256) { (data, error) -> Void in
//                // Create a UIImage, add it to the array
//                //   let pic = UIImage(data: data!)
//                // picArray.append(pic!)
//                self.icon = UIImage(data:data!)
//                
//            }
        //    dbRef.setValue(downloadURL)
            
     //   }
         //   let dbRef = database.reference().child("myFiles")
//            dbRef.observe(.childAdded, with: { (snapshot) in
//                // Get download URL from snapshot
//                if (!snapshot.exists()){
//                print("not exsit db ref")
//                    return 
//                }
//                
//                
//                let downloadURL = snapshot.value as! String
//                // Create a storage reference from the URL
//                
//                }
//            })
        
        // Create a reference to the file you want to download
      //  storage?.reference().child("brand_icon/+\placeName\+\placeName\+.png")
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
                
                 print("get open ans: \(value)")
           
                if (value){
                
                    self.icon = UIImage(data:data!)?.roundedImageWithBorder(width: 2, color: UIColor.green)
                }
                else{
                    // Data for "images/island.jpg" is returned
                    self.icon = UIImage(data:data!)?.roundedImageWithBorder(width: 2, color: UIColor.red)
                
                }
              
             
            }
        }
        
    return true
    }
}

