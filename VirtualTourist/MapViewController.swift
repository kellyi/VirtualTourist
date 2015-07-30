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
    
    @IBOutlet weak var tapPinsNotificationView: UIView!
    
    // MARK: - Setup UIViews
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "editButtonPressed")
        self.navigationItem.rightBarButtonItem = editButton
        self.title = "VirtualTourist"
        tapPinsNotificationView.backgroundColor = UIColor.redColor()
        tapPinsNotificationView.hidden = true
    }
    
    func editButtonPressed() {
        if self.navigationItem.rightBarButtonItem?.title == "Edit" {
            self.navigationItem.rightBarButtonItem?.title = "Done"
            edit()
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            done()
        }
    }

    func edit() {
        tapPinsNotificationView.hidden = false
        println("edit")
    }
    
    func done() {
        tapPinsNotificationView.hidden = true
        println("done")
    }
}

