//
//  ViewController.swift
//  MapBlender
//
//  Created by MacOS on 7/8/17.
//  Copyright © 2017 MacOS. All rights reserved.
//


// call"https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photoreference=(reference)&key=replaceWithYourApiKey"

import UIKit
import GoogleMaps
import Firebase
import FirebaseDatabase
import GooglePlaces

class ViewController: UIViewController,CLLocationManagerDelegate{
//
    @IBOutlet weak var mapView: GMSMapView!

    @IBOutlet weak var addressLabel: UILabel!
    var apiServerKey = ""
    var locationManager = CLLocationManager()
    //let Provider = Goo()
    let searchRadius: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.zoomGestures = true
        mapView.delegate = self
        
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        let ref = FIRDatabase.database().reference(withPath: "/places")
        print(ref)
        ref.observeSingleEvent(of: .value , with: { snapshot in
            let value = snapshot.value as? NSDictionary
            print("data"+"\(value)")
        
        }) {(error)in print (error.localizedDescription)}
    }
//
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.mapView?.animate(to: camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                print(address)
                // 3
               self.addressLabel.unlock()
                let lines = address.lines as [String]?
                self.addressLabel.text = lines?.joined(separator: "\n")
                
                // 4
                UIView.animate(withDuration: 0.25) {
              //      self.view.layoutIfNeeded()
                  let labelHeight = self.addressLabel.intrinsicContentSize.height
                   self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0,
                                                  bottom: labelHeight, right: 0)
                }
                
                        self.view.layoutIfNeeded()
                
            }
        }
    }
    
}


// MARK: - GMSMapViewDelegate
extension ViewController: GMSMapViewDelegate {
 
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(coordinate: position.target)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        addressLabel.lock()
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        // 1
       // let placeMarker = marker as! PlaceMarker
        
        // 2
        if let infoView = UIView.viewFromNibName(name: "MarkerInfoView") as? MarkerInfoView {
            // 3
        //    infoView.nameLabel.text = placeMarker.place.name
     //       infoView.loadFirstPhotoForPlace(placeID: PlaceMarker.getPlaceID(PlaceMarker))
            // 4
        //    if let photo = placeMarker.place.{
        //        infoView.placePhoto.image = photo
          //  } else {
          //      infoView.placePhoto.image = UIImage(named: "generic")
          //  }
            
            return infoView
        } else {
            return nil
        }
    }
}

