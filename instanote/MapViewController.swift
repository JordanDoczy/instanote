//
//  MapViewController.swift
//  instanote
//
//  Created by Jordan Doczy on 12/1/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
 
    // MARK: Private Members
    struct Constants{
        struct CellIdentifiers{
            static let AnnotationViewReuseIdentifier = "annotation"
        }
        struct Selectors {
            static let AnnotationPressed:Selector = #selector(MapViewController.annotationPressed(_:))
            static let AnnotationTapped:Selector = #selector(MapViewController.annotationTapped(_:))
        }
        struct Segues {
            static let EditNote = "Edit Note"
            static let ShowImage = "Show Image"
        }

        static let ImageSize = CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50))
    }
    
    fileprivate var firstAppear:Bool = true
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    fileprivate var selectedAnnotation:MKAnnotation?
    fileprivate var selectedNote:Note?
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView! {
        didSet{
            mapView.delegate = self
        }
    }

    // MARK: IBActions
    @IBAction func showAll(_ sender: UIBarButtonItem?=nil) {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    
    // MARK: View Controller Lifecycle
    override func viewDidLoad(){
        super.viewDidLoad()
        title = "Locations"
        initializeFetchedResultsController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear{
            showAll()
            firstAppear = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    // MARK: Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.EditNote || segue.identifier == Constants.Segues.ShowImage{
            var destination = segue.destination
            
            if let navController = destination as? UINavigationController {
                destination = navController.visibleViewController!
            }
            if var controller = destination as? NoteDataSource{
                controller.note = selectedNote
            }
        }
    }
    
    
    // MARK: UIGestureRecognizers
    func annotationPressed(_ sender:UILongPressGestureRecognizer){
        if sender.state == .began {
            if let view = sender.view as? MKAnnotationView{
                if let note = view.annotation {
                    selectedNote = note as? Note
                    performSegue(withIdentifier: Constants.Segues.EditNote, sender: self)
                }
            }
        }
    }
    
    func annotationTapped(_ sender:UITapGestureRecognizer){
        if let view = sender.view as? MKPinAnnotationView {
            
            if view.annotation!.isEqual(selectedAnnotation){
                selectedNote = view.annotation as? Note
                performSegue(withIdentifier: Constants.Segues.ShowImage, sender: self)
            }
            else{
                view.isEnabled = true
                selectedAnnotation = view.annotation
                mapView.selectAnnotation(view.annotation!, animated: true)
            }
        }
    }

    // MARK: NSFetchedResultsController Protocol
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateAnnotations()
    }

    
    // MARK: MapView Protocol
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.CellIdentifiers.AnnotationViewReuseIdentifier)
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.CellIdentifiers.AnnotationViewReuseIdentifier)
            view!.canShowCallout = true
            (view as! MKPinAnnotationView).animatesDrop = true
        } else {
            view!.annotation = annotation
        }
        
        view!.leftCalloutAccessoryView = UIButton(frame: Constants.ImageSize)
        
        let button = UIButton(type: .custom)
        var image = UIImage(named: Assets.Edit)
        image = image?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: UIControlState())
        button.tintColor = Colors.Primary
        button.isUserInteractionEnabled = true
        button.sizeToFit()
        
        view!.rightCalloutAccessoryView = button

        
        let press = UILongPressGestureRecognizer(target: self, action: Constants.Selectors.AnnotationPressed)
        press.minimumPressDuration = 0.33
        view?.addGestureRecognizer(press)

        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? Note {
            if let imageURLString = annotation.imagePath {
                if imageURLString == Assets.SampleImage || imageURLString == Assets.DefaultImage{
                     setImageForPin(view, image: UIImage(named: imageURLString)!)
                }
                else if let imageURL = URL(string: imageURLString){
                    _ = UIImage.fetchImage(imageURL){ [weak self] (image, _) in
                        self?.setImageForPin(view, image: image!)
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if selectedAnnotation != nil{
            if view.annotation!.isEqual(selectedAnnotation) {
                mapView.selectAnnotation(view.annotation!, animated: false)
                view.isEnabled = false
                selectedAnnotation = nil
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        selectedNote = view.annotation as? Note
        
        if control == view.leftCalloutAccessoryView{
            performSegue(withIdentifier: Constants.Segues.ShowImage, sender: self)
        }
        else if control == view.rightCalloutAccessoryView{
            performSegue(withIdentifier: Constants.Segues.EditNote, sender: self)
        }
        
    }
    
    // MARK: Private Methods
    fileprivate func setImageForPin(_ view:MKAnnotationView, image:UIImage){
        if view.leftCalloutAccessoryView == nil{
            view.leftCalloutAccessoryView = UIButton(frame: Constants.ImageSize)
            view.leftCalloutAccessoryView!.contentMode  = .scaleAspectFill
        }
        if let thumbnailImage = view.leftCalloutAccessoryView as? UIButton{
            thumbnailImage.setImage(image, for: UIControlState())
        }
        
    }
    
    fileprivate func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.Note)
        let sort = NSSortDescriptor(key: Note.Constants.Properties.Date, ascending: true)
        request.sortDescriptors = [sort]
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: AppDelegate.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            updateAnnotations()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    fileprivate func updateAnnotations(){
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        if let count = fetchedResultsController.fetchedObjects?.count {
            if count > 0 {
                mapView.addAnnotations(fetchedResultsController.fetchedObjects as! [MKAnnotation])
                showAll()
            }
        }
        
    }
}
