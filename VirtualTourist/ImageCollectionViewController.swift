//
//  ImageCollectionViewController.swift
//  VirtualTourist
//
//  Created by Kelly Innes on 8/1/15.
//  Copyright (c) 2015 Kelly Innes. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ImageCollectionViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {

    // MARK: - Variables
    
    var pin: Pin!
    var pic: Photo?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tempImageView: UIImageView!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!

    @IBOutlet weak var newCollectionButton: UIButton!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin);
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
    }()
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    // MARK: - Setup UIViews
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addPinAnnotationAndCenter()
        testFlickrClient(pin)
    }
    
    // MARK: - MapView Methods
    
    func addPinAnnotationAndCenter() {
        let deltaValue = 0.5
        let longitudeDelta = CLLocationDegrees(deltaValue)
        let latitudeDelta = CLLocationDegrees(deltaValue)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let region = MKCoordinateRegion(center: pin.coordinate, span: span)
        mapView.setRegion(region, animated: false)
        mapView.addAnnotation(pin)
        mapView.setCenterCoordinate(pin.coordinate, animated: false)
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
        // let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        // return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // let pic = fetchedResultsController.objectAtIndexPath(indexPath) as Photo
        // TODO: implement
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageViewCell", forIndexPath: indexPath) as! UICollectionViewCell
        cell.backgroundColor = UIColor.greenColor()
        return cell
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
        // TODO: implement
    }
    
    // MARK: - Test
    
    func testFlickrClient(pin: Pin) {
        FlickrClient.sharedInstance().getPhotosUsingCompletionHandler(pin) { (success, errorString) in
            if success {
                if pin.photos.count >= 1 {
                    self.pic = Array(pin.photos)[0]
                    println(pin.photos.count)
                    if let imageURL = self.pic?.flickrURL {
                        let convertedImageURL = NSURL(string: imageURL)
                        let imageData = NSData(contentsOfURL: convertedImageURL!)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tempImageView.image = UIImage(data: imageData!)
                        })
                    }
                }
            } else {
                println(errorString)
            }
        }
    }
}
