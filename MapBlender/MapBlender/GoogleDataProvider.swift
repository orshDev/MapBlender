//
//  GoogleDataProvider.swift
//  Feed Me
//

import UIKit
import Foundation
import CoreLocation
import GooglePlaces
import SwiftyJSON


class GoogleDataProvider {
  var photoCache = [String:UIImage]()
  var placesTask: URLSessionDataTask?
     var placesArray = [GMSPlace]()
    var  placeCount = 100
    var  placeIndex = 0
    typealias JSONDictionary = [String:Any]
    var placesClient: GMSPlacesClient?

    var session: URLSession {
    return URLSession.shared
  }
  
    func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, types:[String], completion: @escaping (([GMSPlace]) -> Void)) -> ()
  {
   
    var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true&key=AIzaSyC6F4dJRwgXx0yszrJVRG8jx-xKGr5i_B4"
    print(urlString)
    let typesString = types.count > 0 ? types.joined(separator: "|") : "food"
    urlString += "&types=\(typesString)"
    urlString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
 
    let myGroup = DispatchGroup()
    myGroup.enter()
    //// Do your task
     print("enter task.")
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    let task = session.dataTask(with: NSURL(string: urlString)! as URL) {
        data, response, error in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if let aData = data {
            

            self.placesArray = [GMSPlace]()
            let json = JSON(data:aData, options:JSONSerialization.ReadingOptions.mutableContainers, error:nil)
           // let placesClient = GMSPlacesClient.init()
            self.placesClient = GMSPlacesClient.shared()
            if let results = json["results"].arrayObject as? [[String : AnyObject]]
            {
                 self.placeIndex = 0
                 self.placeCount = results.count
                 var i = 1
                print("the search result count \(results.count)")
                for rawPlace:JSONDictionary in results
                {
                                      
                    let placeId = rawPlace["place_id"] as! String
                 guard let OpenHours = rawPlace["opening_hours"] as? [String : AnyObject]
                    else{
                    print("not found open hours")
                        i = i + 1
                        continue
                    }

                   let openNowStatus = OpenHours["open_now"] as? Bool
                    
                    self.placesClient?.lookUpPlaceID(placeId, callback:
                        { (place, error) -> Void in
                            if let error = error
                            {
                                print("lookup place id query error: \(error.localizedDescription)")
                                return
                            }
                            
                            guard let place = place else
                            {
                                print("No place details for \(placeId)")
                                return
                            }
                            place.setValue(openNowStatus,forKey: "isAccessibilityElement")
                            
                            self.placesArray.append(place)
                            self.placeIndex = self.placeIndex + 1
                            
                            if (i == results.count){
                             completion(self.placesArray)
                            }
                            i = i + 1
                    })
                    
                                   }
            }
            
            
        }
  
    }
     print("Finished all 1.")
    task.resume()
    
    // When task complete
    myGroup.leave()
    print("finish task.")
 
    

 }
  
  
}
