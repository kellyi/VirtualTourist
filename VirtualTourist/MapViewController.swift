//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Kelly Innes on 7/29/15.
//  Copyright (c) 2015 Kelly Innes. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Setup UIViews
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "edit")
        self.navigationItem.rightBarButtonItem = editButton
        self.title = "VirtualTourist"
    }
    
    func edit() {
        println("Hello World!")
    }


}

