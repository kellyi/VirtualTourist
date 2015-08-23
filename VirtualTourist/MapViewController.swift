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
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tapPinsNotificationView: UIView!
    
    // NSManagedObjectContext
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    // NSFetchedResultsController
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
    
    // Set back button text, restore saved pins and mapView region, configure NSFetchedResultsController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
        restoreMapRegion(false)
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
        restorePersistedAnnotations()
    }
    
    // Add "Edit" button and designate its action, set navigationBar title, add gestureRecognizer for adding pins to the map, set and hide subview for deleting pins
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
    
    // Route edit button action depending on current button title
    func editButtonPressed() {
        self.navigationItem.rightBarButtonItem?.title == "Edit" ? edit() : done()
    }

    // Move keyboard up and remove pins on tap
    func edit() {
        self.navigationItem.rightBarButtonItem?.title = "Done"
        tapPinsNotificationView.hidden = false
        mapView.frame.origin.y -= tapPinsNotificationView.frame.height
    }
    
    // Move keyboard down and resume adding pins
    func done() {
        self.navigationItem.rightBarButtonItem?.title = "Edit"
        tapPinsNotificationView.hidden = true
        mapView.frame.origin.y += tapPinsNotificationView.frame.height
    }
    
    // MARK: - MapView and Pin Annotation Methods
    
    // Add new Pin objects to the map, save them in Core Data
    // Ignore longPress if view's in "Tap Pins to Delete" mode
    func annotate(gestureRecognizer: UIGestureRecognizer) {
        if self.navigationItem.rightBarButtonItem?.title == "Done" {
            return
        } else if gestureRecognizer.state == UIGestureRecognizerState.Began {
            var touchPoint = gestureRecognizer.locationInView(mapView)
            var newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let pinAnnotation = Pin(annotationLatitude: newCoordinates.latitude, annotationLongitude: newCoordinates.longitude, context: sharedContext)
            mapView.addAnnotation(pinAnnotation)
            getPhotosUsingFlickrClient(pinAnnotation)
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    // For selected pin:
    // - Segue to ImageCollectionViewController OR
    // - Delete Pin from mapView and from Core Data
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if self.navigationItem.rightBarButtonItem?.title == "Edit" {
            let imageCollectionVC = self.storyboard!.instantiateViewControllerWithIdentifier("imageCollectionVC") as! ImageCollectionViewController
            let pin = view.annotation as! Pin
            imageCollectionVC.pin = pin
            mapView.deselectAnnotation(view.annotation, animated: false)
            navigationController!.pushViewController(imageCollectionVC, animated: true)
        } else {
            let pin = view.annotation as! Pin
            mapView.removeAnnotation(pin)
            sharedContext.deleteObject(pin)
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    // Restore saved Pin objects
    func restorePersistedAnnotations() {
        let restoredPins = fetchedResultsController.fetchedObjects as! [Pin]
        for pin in restoredPins { mapView.addAnnotation(pin) }
    }
    
    // Animate annotations
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var pin = MKPinAnnotationView()
        pin.annotation = annotation
        pin.animatesDrop = true
        return pin
    }
    
    // Download photos from Flickr as soon as the Pin is dropped on the map
    func getPhotosUsingFlickrClient(pin: Pin) {
        FlickrClient.sharedInstance().getPhotosUsingCompletionHandler(pin) { (success, errorString) in
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate Methods
    
    // Satisfy the compiler that the NSFetchedResultsControllerDelegate's set up
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
    }
    
    // MARK: - Persist Chosen Map Region Using NSKeyedArchiver
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    // Save region with NSKeyedArchiver
    func saveMapRegion() {
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
    
    // Restore region with NSKeyedArchiver
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
}

// Save map region each time the mapView's region changes
extension MapViewController : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
}