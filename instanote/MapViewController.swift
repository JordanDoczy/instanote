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
            static let AnnotationPressed:Selector = "annotationPressed:"
            static let AnnotationTapped:Selector = "annotationTapped:"
        }
        struct Segues {
            static let EditNote = "Edit Note"
            static let ShowImage = "Show Image"
        }

        static let ImageSize = CGRect(origin: CGPointZero, size: CGSize(width: 50, height: 50))
    }
    
    private var firstAppear:Bool = true
    private var fetchedResultsController: NSFetchedResultsController!
    private var selectedAnnotation:MKAnnotation?
    private var selectedNote:Note?
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView! {
        didSet{
            mapView.delegate = self
        }
    }

    // MARK: IBActions
    @IBAction func showAll(sender: UIBarButtonItem?=nil) {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    
    // MARK: View Controller Lifecycle
    override func viewDidLoad(){
        super.viewDidLoad()
        title = "Locations"
        initializeFetchedResultsController()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear{
            showAll()
            firstAppear = false
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    // MARK: Overrides
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.Segues.EditNote || segue.identifier == Constants.Segues.ShowImage{
            var destination = segue.destinationViewController
            
            if let navController = destination as? UINavigationController {
                destination = navController.visibleViewController!
            }
            if var controller = destination as? NoteDataSource{
                controller.note = selectedNote
            }
        }
    }
    
    
    // MARK: UIGestureRecognizers
    func annotationPressed(sender:UILongPressGestureRecognizer){
        if sender.state == .Began {
            if let view = sender.view as? MKAnnotationView{
                if let note = view.annotation {
                    selectedNote = note as? Note
                    performSegueWithIdentifier(Constants.Segues.EditNote, sender: self)
                }
            }
        }
    }
    
    func annotationTapped(sender:UITapGestureRecognizer){
        if let view = sender.view as? MKPinAnnotationView {
            
            if view.annotation!.isEqual(selectedAnnotation){
                selectedNote = view.annotation as? Note
                performSegueWithIdentifier(Constants.Segues.ShowImage, sender: self)
            }
            else{
                view.enabled = true
                selectedAnnotation = view.annotation
                mapView.selectAnnotation(view.annotation!, animated: true)
            }
        }
    }

    // MARK: NSFetchedResultsController Protocol
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        updateAnnotations()
    }

    
    // MARK: MapView Protocol
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.CellIdentifiers.AnnotationViewReuseIdentifier)
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.CellIdentifiers.AnnotationViewReuseIdentifier)
            view!.canShowCallout = true
            (view as! MKPinAnnotationView).animatesDrop = true
        } else {
            view!.annotation = annotation
        }
        
        view!.leftCalloutAccessoryView = UIButton(frame: Constants.ImageSize)
        
        let button = UIButton(type: .Custom)
        var image = UIImage(named: Assets.Edit)
        image = image?.imageWithRenderingMode(.AlwaysTemplate)
        button.setImage(image, forState: .Normal)
        button.tintColor = Colors.Primary
        button.userInteractionEnabled = true
        button.sizeToFit()
        
        view!.rightCalloutAccessoryView = button

        
        let press = UILongPressGestureRecognizer(target: self, action: Constants.Selectors.AnnotationPressed)
        press.minimumPressDuration = 0.33
        view?.addGestureRecognizer(press)

        return view
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let annotation = view.annotation as? Note {
            if let imageURLString = annotation.photo {
                if imageURLString == Assets.SampleImage || imageURLString == Assets.DefaultImage{
                     setImageForPin(view, image: UIImage(named: imageURLString)!)
                }
                else if let imageURL = NSURL(string: imageURLString){
                    UIImage.fetchImage(imageURL){ [unowned self] image, response in
                        self.setImageForPin(view, image: image!)
                    }
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if selectedAnnotation != nil{
            if view.annotation!.isEqual(selectedAnnotation) {
                mapView.selectAnnotation(view.annotation!, animated: false)
                view.enabled = false
                selectedAnnotation = nil
            }
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        selectedNote = view.annotation as? Note
        
        if control == view.leftCalloutAccessoryView{
            performSegueWithIdentifier(Constants.Segues.ShowImage, sender: self)
        }
        else if control == view.rightCalloutAccessoryView{
            performSegueWithIdentifier(Constants.Segues.EditNote, sender: self)
        }
        
    }
    
    // MARK: Private Methods
    private func setImageForPin(view:MKAnnotationView, image:UIImage){
        if view.leftCalloutAccessoryView == nil{
            view.leftCalloutAccessoryView = UIButton(frame: Constants.ImageSize)
            view.leftCalloutAccessoryView!.contentMode  = .ScaleAspectFill
        }
        if let thumbnailImage = view.leftCalloutAccessoryView as? UIButton{
            thumbnailImage.setImage(image, forState: .Normal)
        }
        
    }
    
    private func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: Entities.Note)
        let sort = NSSortDescriptor(key: Note.Constants.Properties.Date, ascending: true)
        request.sortDescriptors = [sort]
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RequestManager.appDelegate.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            updateAnnotations()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    private func updateAnnotations(){
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
