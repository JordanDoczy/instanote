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
    fileprivate struct Constants {
        struct CellIdentifiers{
            static let PhotoCell = "PhotoCell"
        }
        struct Segues{
            static let EditNote = "Edit Note"
            static let ShowImage = "Show Image"
        }
        struct Selectors{
            static let ShowImage:Selector = #selector(PhotoCollectionViewController.showImage(_:))
        }
    }

    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    fileprivate var selectedNote:Note?
    fileprivate lazy var helpView:HelpView = { [unowned self] in
        let lazy = HelpView()
        self.view.isUserInteractionEnabled = true
        self.view.addSubview(lazy)
        lazy.delegate = self
        return lazy
    }()
    
    
    // MARK: IBActions
    @IBAction func viewPhotos(_ segue:UIStoryboardSegue) {}

    //MARK: IBActions
    @IBAction func helpButtonHandler(_ sender: UIBarButtonItem) {
        helpView.show(view.bounds)
    }
    
    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photos"

        collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Constants.Selectors.ShowImage))
        
        initializeFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        helpView.hide()
    }
    
    
    // MARK: Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        
        if let navController = destination as? UINavigationController {
            destination = navController.visibleViewController!
        }
        
        if var controller = destination as? NoteDataSource{
            controller.note = selectedNote
        }
        
    }
    
    // MARK: UIGestureRecognizers
    func showImage(_ sender:UITapGestureRecognizer){
        if let note = getNote(sender.location(in: collectionView)){
            selectedNote = note
            performSegue(withIdentifier: Constants.Segues.ShowImage, sender: self)
        }
    }

    
    // MARK: Private Methods
    fileprivate func getNote(_ point:CGPoint)->Note?{
        if let indexPath = collectionView?.indexPathForItem(at: point){
            if let note = fetchedResultsController.object(at: indexPath) as? Note{
                return note
            }
        }
        return nil
    }
    
    fileprivate func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.Note)
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
    func photoViewCellSelected(_ cell: PhotoViewCell) {
        if let indexPath = collectionView?.indexPath(for: cell){
            selectedNote = fetchedResultsController.object(at: indexPath) as? Note
            performSegue(withIdentifier: Constants.Segues.EditNote, sender: self)
        }
    }
    
    // MARK: UIHelpView Protocol
    func helpViewDidHide() {
        collectionView!.isScrollEnabled = true
    }
    func helpViewDidShow() {
        collectionView!.isScrollEnabled = false
    }
    
    // MARK: Collection View Protocol
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> PhotoViewCell {
        let note = fetchedResultsController.object(at: indexPath) as! Note

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifiers.PhotoCell, for: indexPath) as! PhotoViewCell
        cell.backgroundColor = Colors.LightGray
        cell.imageURL = note.imagePath
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.delegate = self

        return cell
    }
    
    // MARK: NSFetchedResultsController Protocol
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.reloadData()
    
        if let count = fetchedResultsController.fetchedObjects?.count {
            if count > 0 {
                collectionView?.scrollToItem(at: fetchedResultsController.indexPath(forObject: (fetchedResultsController.fetchedObjects!.first)!)!, at: UICollectionViewScrollPosition(), animated: false)
            }
        }
        
    }
    

}
