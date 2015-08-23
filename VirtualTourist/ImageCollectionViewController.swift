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
    
    // Pin object passed from MapViewController segue
    var pin: Pin!
    
    // NSIndexPath arrays to store selected collectionViewCells to remove
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    // NSFetchedResultsController
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
    
    // NSManagedObjectContext singleton
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    // MARK: - Setup UIViews
    
    // Set collectionViewCells to be 1/3 of the width of the screen
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

    // Setup fetchedResultsController & imageCollectionView
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.allowsMultipleSelection = true
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
    }
    
    // Place pin with preloaded images on map
    //
    // If coordinates from pin location returned no Flickr photos, disable
    // newCollectionButton and change text to report issue
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addPinAnnotationAndCenter()
        if pin.photos.isEmpty {
            newCollectionButton.title = "No Flickr Photos for Coordinates"
            newCollectionButton.enabled = false
        }
    }
    
    // MARK: - NewCollectionButton IBAction & Supporting Methods
    
    // Change newCollectionButton action based on whether any cells are selected
    // for deletion:
    //
    // - if no cells are selected, action should grab a new set of pictures from
    // Flickr, keeping the button disabled until the new pictures have been saved
    // - if => 1 cells are selected, delete the selected images
    @IBAction func newCollectionButtonPressed(sender: AnyObject) {
        if selectedIndexes.isEmpty {
            deleteAllPhotos()
            newCollectionButton.enabled = false
            newCollectionButton.title = "Getting New Photos from Flickr"
            FlickrClient.sharedInstance().getPhotosUsingCompletionHandler(pin) { (success, errorString) in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        CoreDataStackManager.sharedInstance().saveContext()
                        self.imageCollectionView.reloadData()
                        self.newCollectionButton.enabled = true
                        self.newCollectionButton.title = "New Collection"
                    })
                }
                
            }
        } else {
            deleteSelectedPhotos()
        }
        self.imageCollectionView.reloadData()
    }
    
    // Change newCollectionButton title text to represent what it'll do
    func updateBottomButton() {
        if selectedIndexes.count > 0 {
            newCollectionButton.title = "Remove Selected Photos"
        } else {
            newCollectionButton.title = "New Collection"
        }
    }
    
    // Delete all photo objects (and underlying files)
    func deleteAllPhotos() {
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        CoreDataStackManager.sharedInstance().saveContext()
        selectedIndexes = [NSIndexPath]()
    }
    
    // Delete only selected photo objects (and underlying files)
    func deleteSelectedPhotos() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            sharedContext.deleteObject(photo)
        }
        CoreDataStackManager.sharedInstance().saveContext()
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
    
    // Toggle selecting and deselecting cells to delete, toggling the cell's
    // background color from .oceanColor() to .orangeColor()
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageCollectionViewCell
        if let index = find(selectedIndexes, indexPath) {
            selectedIndexes.removeAtIndex(index)
            cell.backgroundColor = UIColor.oceanColor()
        } else {
            selectedIndexes.append(indexPath)
            cell.backgroundColor = UIColor.orangeColor()
        }
        updateBottomButton()
    }
    
    // Set image and initial backgroundColor for each cell
    // Cell starts as .grayColor() as photos load, then to .oceanColor() when done
    func configureCell(cell: ImageCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.grayColor()
        let pic = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        if let photoImage = pic.retrieveImageFromDocumentsDirectory() {
            cell.backgroundColor = UIColor.oceanColor()
            cell.imageCollectionViewCellImage.image = photoImage as UIImage!
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate Methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.imageCollectionView.insertSections(NSIndexSet(index: sectionIndex))
        case .Delete:
            self.imageCollectionView.deleteSections(NSIndexSet(index: sectionIndex))
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type{
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            updatedIndexPaths.append(indexPath!)
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
    
    // Set mapView region to show pin & surroundings
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

