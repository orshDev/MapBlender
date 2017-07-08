//
//  ViewController.swift
//  MapBlender
//
//  Created by MacOS on 7/8/17.
//  Copyright © 2017 MacOS. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {
//
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let ref = FIRDatabase.database().reference(withPath: "places")
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

