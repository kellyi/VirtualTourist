//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Kelly Innes on 7/29/15.
//  Copyright (c) 2015 Kelly Innes. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    // MARK: - Variables
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tapPinsNotificationView: UIView!
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
    }()
    
    // MARK: - Setup UIViews
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
        println(sharedContext)
        restoreMapRegion(false)
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
        restorePersistedAnnotations()
        println(fetchedResultsController.fetchedObjects!.count)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "editButtonPressed")
        self.navigationItem.rightBarButtonItem = editButton
        self.title = "VirtualTourist"
        tapPinsNotificationView.backgroundColor = UIColor.redColor()
        tapPinsNotificationView.hidden = true
        var longPressGR = UILongPressGestureRecognizer(target: self, action: "annotate:")
        longPressGR.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGR)
    }
    
    // MARK: - Handle "Edit" UIBarButtonItem actions
    
    func editButtonPressed() {
        self.navigationItem.rightBarButtonItem?.title == "Edit" ? edit() : done()
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
    
    // MARK: - Add and Remove Annotations
    
    func annotate(gestureRecognizer: UIGestureRecognizer) {
        if self.navigationItem.rightBarButtonItem?.title == "Done" {
            return
        } else if gestureRecognizer.state == UIGestureRecognizerState.Began {
            var touchPoint = gestureRecognizer.locationInView(mapView)
            var newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = Pin(annotationLatitude: newCoordinates.latitude, annotationLongitude: newCoordinates.longitude, context: sharedContext)
            mapView.addAnnotation(annotation)
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if self.navigationItem.rightBarButtonItem?.title == "Edit" {
            let imageCollectionVC = self.storyboard!.instantiateViewControllerWithIdentifier("imageCollectionVC") as! ImageCollectionViewController
            imageCollectionVC.pin = view.annotation as! Pin
            mapView.deselectAnnotation(view.annotation, animated: false)
            let pinLat = view.annotation.coordinate.latitude
            let pinLon = view.annotation.coordinate.longitude
            //testFlickrClient(pinLat, longitude: pinLon)
            navigationController!.pushViewController(imageCollectionVC, animated: true)
        } else {
            let pin = view.annotation as! Pin
            sharedContext.deleteObject(pin)
            mapView.removeAnnotation(pin)
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    func restorePersistedAnnotations() {
        for pin in fetchedResultsController.fetchedObjects as! [Pin] { mapView.addAnnotation(pin) }
    }
    
    // MARK: - Animate Annotation Pin Drop
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var pin = MKPinAnnotationView()
        pin.annotation = annotation
        pin.animatesDrop = true
        return pin
    }
    
    // MARK: - Persist Chosen Map Region
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    func saveMapRegion() {
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
    
    func restoreMapRegion(animated: Bool) {
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(savedRegion, animated: animated)
            mapView.setCenterCoordinate(center, animated: animated)
        }
    }
    
    func testFlickrClient(latitude: Double, longitude: Double) {
        FlickrClient.sharedInstance().getPhotosUsingCompletionHandler(latitude, longitude: longitude) { (success, errorString) in
            success ? println("success") : println("error")
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate Methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // TODO: implement
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        // TODO: implement
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        // TODO: implement
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        println(fetchedResultsController.fetchedObjects!.count)
        // TODO: implement
    }
    
}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
}