//
//  PhotoCollectionViewController.swift
//  instanote
//
//  Created by Jordan Doczy on 12/1/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
import CoreData

class PhotoCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout, UIHelpViewDelegate, PhotoViewCellDelegate {

    // MARK: Private Members
    private struct Constants {
        struct CellIdentifiers{
            static let PhotoCell = "PhotoCell"
        }
        struct Segues{
            static let EditNote = "Edit Note"
            static let ShowImage = "Show Image"
        }
        struct Selectors{
            static let ShowImage:Selector = "showImage:"
        }
    }

    private var fetchedResultsController: NSFetchedResultsController!
    private var selectedNote:Note?
    private lazy var helpView:HelpView = { [unowned self] in
        let lazy = HelpView()
        self.view.userInteractionEnabled = true
        self.view.addSubview(lazy)
        lazy.delegate = self
        return lazy
    }()
    
    
    // MARK: IBActions
    @IBAction func viewPhotos(segue:UIStoryboardSegue) {}

    //MARK: IBActions
    @IBAction func helpButtonHandler(sender: UIBarButtonItem) {
        helpView.show(view.bounds)
    }
    
    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photos"

        collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Constants.Selectors.ShowImage))
        
        initializeFetchedResultsController()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        helpView.hide()
    }
    
    
    // MARK: Overrides
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController
        
        if let navController = destination as? UINavigationController {
            destination = navController.visibleViewController!
        }
        
        if var controller = destination as? NoteDataSource{
            controller.note = selectedNote
        }
        
    }
    
    // MARK: UIGestureRecognizers
    func showImage(sender:UITapGestureRecognizer){
        if let note = getNote(sender.locationInView(collectionView)){
            selectedNote = note
            performSegueWithIdentifier(Constants.Segues.ShowImage, sender: self)
        }
    }

    
    // MARK: Private Methods
    private func getNote(point:CGPoint)->Note?{
        if let indexPath = collectionView?.indexPathForItemAtPoint(point){
            if let note = fetchedResultsController.objectAtIndexPath(indexPath) as? Note{
                return note
            }
        }
        return nil
    }
    
    private func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: Entities.Note)
        request.sortDescriptors = [NSSortDescriptor(key: Note.Constants.Properties.Date, ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: AppDelegate.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    // MARK: PhotoViewCell Protocol
    func photoViewCellSelected(cell: PhotoViewCell) {
        if let indexPath = collectionView?.indexPathForCell(cell){
            selectedNote = fetchedResultsController.objectAtIndexPath(indexPath) as? Note
            performSegueWithIdentifier(Constants.Segues.EditNote, sender: self)
        }
    }
    
    // MARK: UIHelpView Protocol
    func helpViewDidHide() {
        collectionView!.scrollEnabled = true
    }
    func helpViewDidShow() {
        collectionView!.scrollEnabled = false
    }
    
    // MARK: Collection View Protocol
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> PhotoViewCell {
        let note = fetchedResultsController.objectAtIndexPath(indexPath) as! Note

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CellIdentifiers.PhotoCell, forIndexPath: indexPath) as! PhotoViewCell
        cell.backgroundColor = Colors.LightGray
        cell.imageURL = note.imagePath
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.delegate = self

        return cell
    }
    
    // MARK: NSFetchedResultsController Protocol
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView?.reloadData()
    
        if let count = fetchedResultsController.fetchedObjects?.count {
            if count > 0 {
                collectionView?.scrollToItemAtIndexPath(fetchedResultsController.indexPathForObject((fetchedResultsController.fetchedObjects!.first)!)!, atScrollPosition: .None, animated: false)
            }
        }
        
    }
    

}
