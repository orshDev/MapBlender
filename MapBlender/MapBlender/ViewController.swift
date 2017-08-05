//
//  ViewController.swift
//  MapBlender
//
//  Created by MacOS on 7/8/17.
//  Copyright © 2017 MacOS. All rights reserved.
//



import UIKit
import GoogleMaps
import Firebase
import FirebaseDatabase
import GooglePlaces

class ViewController: UIViewController{
//
    @IBOutlet weak var mapView: GMSMapView?

    @IBOutlet weak var addressLabel: UILabel!
    var apiServerKey = ""
    var locationManager = CLLocationManager()
    let Provider = GoogleDataProvider()
    @IBOutlet weak var mapCenterPinImage: UIImageView!
    let searchRadius: Double = 50
   
    var searchedTypes = ["bar", "cafe", "restaurant"]

    @IBOutlet weak var filter: UIButton!
    
    var placePhoto: UIImageView!
    
    @IBOutlet weak var refresh: UIButton!
    
//     var camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6);
//   

    
    override func viewDidLoad() {
        super.viewDidLoad()
      
//        self.mapView = GMSMapView.map(withFrame: CGRect.zero, camera:camera);
//
//        
   
        self.mapView?.delegate = self
        
         self.mapView?.isMyLocationEnabled = true
          self.mapView?.settings.compassButton = true
        self.mapView?.settings.zoomGestures = true
           self.mapView?.settings.myLocationButton = true
        
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()

    //    locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
       
     
        
        let ref = FIRDatabase.database().reference(withPath: "/places")
        // print(ref)
        ref.observeSingleEvent(of: .value , with: { snapshot in
            let value = snapshot.value as? NSDictionary
            print("data"+"\(value)")
            
        }) {(error)in print (error.localizedDescription)}
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! TypesTableViewController
            controller.selectedTypes = searchedTypes
            controller.delegate = self
        }
    
    }
    

    
    
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        // 1
        print("enter fetching")
        mapView?.clear()
        // 2
        // var places = [GMSPlace]()
        Provider.fetchPlacesNearCoordinate(coordinate: coordinate, radius:searchRadius, types: searchedTypes ) {
        places in
            for place: GMSPlace in places {
                // 3
                print("place is+")
                print(place)
                let marker = PlaceMarker(place: place)
                // 4
               // marker.iconpicView?.cropAsCircleWithBorder(borderColor: UIColor.red, strokeWidth: 20)
              //  marker.iconView = marker.markerView
                marker.map = self.mapView
            }
            
        }
    }
    
   //
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

      @IBAction func refresh_action(_ sender: Any) {
        
          fetchNearbyPlaces(coordinate: (mapView?.camera.target)!)
      }
    
    
      @IBAction func filter_action(_ sender: Any) {
        self.performSegue(withIdentifier: "filter_show", sender: self)
      }
    
      func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
              //  print(address)
                // 3
               self.addressLabel.unlock()
                let lines = address.lines as [String]?
                self.addressLabel.text = lines?.joined(separator: "\n")
                
                // 4
                UIView.animate(withDuration: 0.25) {
              //      self.view.layoutIfNeeded()
                  let labelHeight = self.addressLabel.intrinsicContentSize.height
                   self.mapView?.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0,
                                                  bottom: labelHeight, right: 0)
                }
                
                        self.view.layoutIfNeeded()
                
            }
        }
    }
    
}

// MARK: - TypesTableViewControllerDelegate
extension ViewController: TypesTableViewControllerDelegate {
    func typesController(controller: TypesTableViewController, didSelectTypes types: [String]) {
        searchedTypes = controller.selectedTypes.sorted()
        dismiss(animated: true, completion: nil)
        fetchNearbyPlaces(coordinate: (mapView?.camera.target)!)
    }
}

//
// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
      func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView?.isMyLocationEnabled = true
            mapView?.settings.myLocationButton = true
        }
    }
//    
//      func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
//            locationManager.stopUpdatingLocation()
//            print("start fetching")
//            fetchNearbyPlaces(coordinate: location.coordinate)
//        }
//    }
    
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.first
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.mapView?.animate(to: camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        print("start fetching")
        fetchNearbyPlaces(coordinate: (location?.coordinate)!)

        
    }
    

}


// MARK: - GMSMapViewDelegate
extension ViewController: GMSMapViewDelegate {
 
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(coordinate: position.target)
        
        
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        addressLabel.lock()
        
        if (gesture) {
            mapCenterPinImage.fadeIn(duration: 0.25)
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        let placeMarker = marker as! PlaceMarker
        
      print(placeMarker.place.website?.absoluteString ?? "not found")
        
//        if let infoView = UIView.viewFromNibName(name: "MarkerInfoView") as? MarkerInfoView {
//            infoView.nameLabel.text = placeMarker.place.name
//            
//            
//            if let photo = placeMarker.icon {
//                infoView.placePhoto.image = photo
//                infoView.placePhoto.cropAsCircleWithBorder(borderColor: UIColor.red, strokeWidth: 20)
//            } else {
//               // infoView.placePhoto.image = UIImage(named: "generic")
//            }
//            
//            return infoView
//        } else {
//            return nil
//        }
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapCenterPinImage.fadeOut(duration: 0.25)
        return false
    }
    
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        mapCenterPinImage.fadeIn(duration: 0.25)
        mapView.selectedMarker = nil
        return false
    }}

