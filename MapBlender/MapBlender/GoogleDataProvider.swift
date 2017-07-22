//
//  GoogleDataProvider.swift
//  Feed Me
//
/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

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
    
    
    var session: URLSession {
    return URLSession.shared
  }
  
    func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, types:[String], completion: @escaping (([GMSPlace]) -> Void)) -> ()
  {
   // var task = placesTask
   // var url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photoreference=(reference)&key=AIzaSyDLN1yrUHGslEtcxgeJTrfIRJBjoFryXl4"
    
    var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true&key=AIzaSyCI7rHEvomd2qbWY5dXH9Yews6kU87goA4"
    print(urlString)
    let typesString = types.count > 0 ? types.joined(separator: "|") : "food"
    urlString += "&types=\(typesString)"
    urlString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    
  //  if let task = placesTask, task.taskIdentifier > 0 && task.state == .running {
   //  task.cancel()
  // }
    
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
            let placesClient = GMSPlacesClient.init()
            
            if let results = json["results"].arrayObject as? [[String : AnyObject]]
            {
                 self.placeIndex = 0
                 self.placeCount = results.count
                 var i = 1
                print("the search result count \(results.count)")
                for rawPlace in results
                {
                    
                    let placeId = rawPlace["place_id"] as! String
                    
                    placesClient.lookUpPlaceID(placeId, callback:
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
                            print("callback \(i)")
                            
                            print("Place name \(place.name)")
                            print("Place address \(place.formattedAddress)")
                            print("Place placeID \(place.placeID)")
                            print("Place attributions \(place.attributions)")
                            
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
    

    
    //// When you task complete
    myGroup.leave()
    print("finish task.")
 
    

 }
  
  
}
