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
import FirebaseStorage

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
    
     var storage: FIRStorage!
     var infoWindow = MarkerInfoView()
    @IBOutlet weak var refresh: UIButton!
    fileprivate var PlaceMarkerInfo : GMSMarker? = GMSMarker()
  

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.mapView?.delegate = self
        
         self.mapView?.isMyLocationEnabled = true
          self.mapView?.settings.compassButton = true
        self.mapView?.settings.zoomGestures = true
           self.mapView?.settings.myLocationButton = true
        
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()

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
     
        let geocoder = GMSGeocoder()
        
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
           
               self.addressLabel.unlock()
                let lines = address.lines as [String]?
                self.addressLabel.text = lines?.joined(separator: "\n")
                
                
                UIView.animate(withDuration: 0.25) {
             
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
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool{
        // 1
        let placeMarker = marker as! PlaceMarker
         storage = FIRStorage.storage()
        
        // 2
        print("start click")
     
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
         let location = placeMarker.position
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        print("text click \(placeMarker.place.name)")
        infoWindow.text.text = placeMarker.place.name
        let name_brand = placeMarker.place.name

        
      guard let islandRef = storage?.reference().child("brand_icon/\(name_brand)/sale/current sale.png")
        else{
        print("path not exist :brand_icon/\(name_brand)/sale/current sale.png")
            self.view.addSubview(infoWindow)

            return false
        }
        
        islandRef.data(withMaxSize: 1 * 256 * 256) { data, error in
                if data == nil {
                    print("an error occurred!\(error)")
                }
                else{
                    self.infoWindow.picture_sale.image = UIImage(data:data!)
                    }
            
            
            
            
        
        }
        self.view.addSubview(infoWindow)
        
        return false
        
        

    }
    
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
           guard let location = PlaceMarkerInfo?.position else {
               print("locationMarker is nil")
               return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        }
    
    
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    // MARK: Needed to create the custom info window
    func sizeForOffset(view: UIView) -> CGFloat {
        return  60.0
    }
    
    // MARK: Needed to create the custom info window
    func loadNiB() -> MarkerInfoView{
        let infoWindow = MarkerInfoView.instanceFromNib() as! MarkerInfoView
        return infoWindow
    }
    
  
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        mapCenterPinImage.fadeIn(duration: 0.25)
        mapView.selectedMarker = nil
        return false
        }
}


