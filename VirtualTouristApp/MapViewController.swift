//
//  MapViewController.swift
//  VirtualTouristApp
//
//  Created by Pulkit  Gupta on 18/12/16.
//  Copyright © 2016 Pulkit  Gupta. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: MapViewControllerExtension, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var selectedPin:Pin!
    var lastAddedPin:Pin? = nil
    var isEditMode = false
    var mapViewRegion:MapRegion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addPin(_:)))
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
        
        loadMapRegion()
        mapView.addAnnotations(fetchAllPins())
    }
    
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        var pins:[Pin] = []
        do {
            let results = try sharedContext.fetch(fetchRequest)
            pins = results as! [Pin]
        } catch let error as NSError {
            showAlert("Ooops", message: "Something went wrong when trying to load existing data")
            print("An error occured accessing managed object context \(error.localizedDescription)")
        }
        return pins
    }
    func addPin(_ gestureRecognizer: UIGestureRecognizer) {
        
        if isEditMode {
            return
        }
        
        let locationInMap = gestureRecognizer.location(in: mapView)
        let coord:CLLocationCoordinate2D = mapView.convert(locationInMap, toCoordinateFrom: mapView)
        
        switch gestureRecognizer.state {
        case UIGestureRecognizerState.began:
            lastAddedPin = Pin(coordinate: coord, context: sharedContext)
            mapView.addAnnotation(lastAddedPin!)
        case UIGestureRecognizerState.changed:
            lastAddedPin!.willChangeValue(forKey: "coordinate")
            lastAddedPin!.coordinate = coord
            lastAddedPin!.didChangeValue(forKey: "coordinate")
        case UIGestureRecognizerState.ended:
            getPhotosForPin(lastAddedPin!) { (success, errorString) in
                self.lastAddedPin!.isDownloading = false
                if success == false {
                    self.showAlert("An error occurred", message: errorString!)
                    return
                }
            }
            CoreDataStackManager.sharedInstance().saveContext()
        default:
            return
        }
        
    }
    func deletePin(_ pin: Pin) {
        mapView.removeAnnotation(pin)
        sharedContext.delete(pin)
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    @IBAction func editMapPinsAction(_ sender: Any) {
        if isEditMode {
            isEditMode = false
            editButton.title = "Edit"
        } else {
            isEditMode = true
            editButton.title = "Done"
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? Pin {
            let identifier = "Pin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                view.animatesDrop = true
                view.isDraggable = false
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Pin selected")
        let annotation = view.annotation as! Pin
        selectedPin = annotation
        if !isEditMode {
            performSegue(withIdentifier: "locationDetail", sender: self)
        } else {
            let alert = UIAlertController(title: "Delete Pin", message: "Do you want to remove this pin?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
                self.selectedPin = nil
                self.deletePin(annotation)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("Saving Map Coordinates")
        saveMapRegion()
    }
    
    struct mapKeys {
        static let centerLatitude = "CenterLatitudeKey"
        static let centerLongitude = "CenterLongitude"
        static let spanLatitude = "SpanLatitudeDeltaKey"
        static let spanLongitude = "SpanLongitudeDeltaKey"
    }
    
    
    func saveMapRegion() {
        if mapViewRegion == nil {
            mapViewRegion = MapRegion(region: mapView.region, context: sharedContext)
        } else {
            mapViewRegion!.region = mapView.region
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func loadMapRegion() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MapRegion")
        var regions:[MapRegion] = []
        do {
            let results = try sharedContext.fetch(fetchRequest)
            regions = results as! [MapRegion]
        } catch let error as NSError {
            // only map region failed, so failing silent
            print("An error occured accessing managed object context \(error.localizedDescription)")
        }
        if regions.count > 0 {
            mapViewRegion = regions[0]
            mapView.region = mapViewRegion!.region
        } else {
            mapViewRegion = MapRegion(region: mapView.region, context: sharedContext)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationDetail" {
            mapView.deselectAnnotation(selectedPin, animated: false)
            let controller = segue.destination as!
            PhotoAlbumViewController
            controller.pin = selectedPin
        }
    }
    
    
}


