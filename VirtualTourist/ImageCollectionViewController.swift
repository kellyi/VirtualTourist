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
    
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.imageCollectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        imageCollectionView.collectionViewLayout = layout
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.allowsMultipleSelection = true
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addPinAnnotationAndCenter()
        if pin.photos.isEmpty {
            newCollectionButton.title = "No Flickr Photos for Coordinates"
            newCollectionButton.enabled = false
        }
    }
    
    // MARK: - NewCollectionButton IBAction & Supporting Methods
    
    @IBAction func newCollectionButtonPressed(sender: AnyObject) {
        if selectedIndexes.isEmpty {
            deleteAllPhotos()
            FlickrClient.sharedInstance().getPhotosUsingCompletionHandler(pin) { (success, errorString) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.imageCollectionView.reloadData()
                })
                CoreDataStackManager.sharedInstance().saveContext()
            }
            self.imageCollectionView.reloadData()
        } else {
            deleteSelectedPhotos()
        }
    }
    
    func updateBottomButton() {
        if selectedIndexes.count > 0 {
            newCollectionButton.title = "Remove Selected Photos"
        } else {
            newCollectionButton.title = "New Collection"
        }
    }
    
    func deleteAllPhotos() {
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            photo.deleteFile()
            sharedContext.deleteObject(photo)
        }
        selectedIndexes = [NSIndexPath]()
    }
    
    func deleteSelectedPhotos() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            photo.deleteFile()
            sharedContext.deleteObject(photo)
        }
        
        selectedIndexes = [NSIndexPath]()
        updateBottomButton()
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageViewCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageCollectionViewCell
        cell.backgroundView?.backgroundColor = .orangeColor()
        
        if let index = find(selectedIndexes, indexPath) {
            selectedIndexes.removeAtIndex(index)
            cell.backgroundView?.backgroundColor = UIColor.oceanColor()
        } else {
            selectedIndexes.append(indexPath)
            cell.backgroundView?.backgroundColor = UIColor.orangeColor()
        }
        
        configureCell(cell, atIndexPath: indexPath)
        updateBottomButton()
    }
    
    func configureCell(cell: ImageCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        /*
        cell.imageCollectionViewCellImage.image = nil
        let photo = pin.photos[indexPath.row] as Photo
        if photo.flickrURL == nil || photo.flickrURL == "" {
            return
        } else if photo.photoImage != nil {
            cell.imageCollectionViewCellImage.image = photo.photoImage
        } else {
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.hidden = false
            /*
            FlickrClient.sharedInstance().taskForImageWithSize(photo.flickrURL!) { data, error in
                
                if let data = data {
                    photo.photoImage = UIImage(data: data)
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.activityIndicator.stopAnimating()
                        cell.activityIndicator.hidden = true
                        cell.imageCollectionViewCellImage.image = photo.photoImage
                        //self.loadedImages++
                        //if self.loadedImages == self.fetchedResultsController.fetchedObjects?.count {
                        //    self.newCollectionButton.enabled = true
                        //}
                        
                    }
                }
            }
            */
        }
        
        */
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.hidden = false
        let pic = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        println(pic.imagePath)
        if let photoImage = pic.retrieveImageFromDocumentsDirectory() {
            cell.imageCollectionViewCellImage.image = photoImage as UIImage!
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.hidden = true
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate Methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        /*
        switch type {
        case .Insert:
            self.imageCollectionView.insertSections(NSIndexSet(index: sectionIndex))
        case .Delete:
            self.imageCollectionView.deleteSections(NSIndexSet(index: sectionIndex))
        default:
            return
        }
        */
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type{
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        imageCollectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.imageCollectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.imageCollectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.imageCollectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
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

}

// MARK: - Add Ocean UIColor
extension UIColor {
    
    class func oceanColor() -> UIColor {
        return UIColor(red:0/255, green:64/255, blue:128/255, alpha:1.0)
    }

}

