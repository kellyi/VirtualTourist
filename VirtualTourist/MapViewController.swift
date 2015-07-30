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
    
    // MARK: - Handle "Edit" UIBarButtonItem actions
    
    func editButtonPressed() {
        if self.navigationItem.rightBarButtonItem?.title == "Edit" {
            edit()
        } else {
            done()
        }
    }

    func edit() {
        self.navigationItem.rightBarButtonItem?.title = "Done"
        tapPinsNotificationView.hidden = false
        mapView.frame.origin.y -= tapPinsNotificationView.frame.height
    }
    
    func done() {
        self.navigationItem.rightBarButtonItem?.title = "Edit"
        tapPinsNotificationView.hidden = true
        mapView.frame.origin.y += tapPinsNotificationView.frame.height
    }
}

