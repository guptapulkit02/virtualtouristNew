//
//  PhotoAlbumViewContoller.swift
//  VirtualTouristApp
//
//  Created by Pulkit  Gupta on 18/12/16.
//  Copyright © 2016 Pulkit  Gupta. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: MapViewControllerExtension, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    var pin:Pin!
    
    var selectedIndexes   = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths : [IndexPath]!
    var updatedIndexPaths : [IndexPath]!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        noImagesLabel.isHidden = true
        collectionView.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.addAnnotation(pin)
        mapView.setCenter(pin.coordinate, animated: true)
        
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
            print(error!)
        }
        
        if error != nil  || fetchedResultsController.fetchedObjects?.count == 0 {
            loadNewCollectionSet()
        }
        
        if pin.isDownloading {
            newCollectionButton.isEnabled = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(PhotoAlbumViewController.pinFinishedDownload), name: NSNotification.Name(rawValue: pinFinishedDownloadingNotification), object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func loadNewCollectionSet() {
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.delete(photo)
        }
        CoreDataStackManager.sharedInstance().saveContext()
        
        self.newCollectionButton.isEnabled = false
        print(pin.photos.count)
        
        getPhotosForPin(pin) { (success, errorString) in
            self.pinFinishedDownload()
            
            if success == false {
                self.showAlert("An error occurred", message: errorString!)
                return
            }
        }
    }
    
    func pinFinishedDownload() {
        if pin.isDownloading == true {
            return
        }
        self.newCollectionButton.isEnabled = true
        
        if let objects = self.fetchedResultsController.fetchedObjects {
            if objects.count == 0 {
                self.collectionView.isHidden = true
                self.noImagesLabel.isHidden = false
                self.newCollectionButton.isEnabled = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        DispatchQueue.main.async {
            cell.imageView.image = nil
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.isHidden = false
        }
        let photo = fetchedResultsController.object(at: indexPath) as! Photo
        
        if photo.imagePath != nil {
            cell.activityIndicator.stopAnimating()
            cell.imageView.image = photo.image
        }
        
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath) as! Photo
        let alert = UIAlertController(title: "Delete Photo", message: "Do you want to remove this photo?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction) in
            collectionView.deselectItem(at: indexPath, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
            collectionView.deselectItem(at: indexPath, animated: true)
            self.sharedContext.delete(photo)
            CoreDataStackManager.sharedInstance().saveContext()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func newCollectionAction(_ sender: Any) {
        loadNewCollectionSet()
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.sortDescriptors = []
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>
    }()
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths  = [IndexPath]()
        updatedIndexPaths  = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
        case .update:
            updatedIndexPaths.append(indexPath!)
        case .delete:
            deletedIndexPaths.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }, completion: nil)
    }
}
