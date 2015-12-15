//
//  ListViewController.swift
//  instanote
//
//  Created by Jordan Doczy on 12/1/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, UIHelpViewDelegate, ListViewCellDelegate {
    
    // MARK: Private Members
    private struct Constants {
        struct CellIdentifiers{
            static let ListViewCell = "ListViewCell"
        }
        struct Selectors {
            static let CloseSearch:Selector = "closeSearch:"
            static let CellSelected:Selector = "cellSelected:"
        }
        struct Segues {
            static let EditNote = "Edit Note"
        }
        struct TableView {
            static let EstimatedRowHeight:CGFloat = 85
            static let ImageMultiplier:CGFloat = 3
            static let SelectedRowHeight:CGFloat = 215
        }
    }
    
    private lazy var helpView:HelpView = { [unowned self] in
       let lazy = HelpView()
        self.view.superview!.addSubview(lazy)
        lazy.delegate = self
        return lazy
    }()
    private var fetchImageOperationQueue:NSOperationQueue = NSOperationQueue()
    private var fetchedResultsController: NSFetchedResultsController!
    private var filteredResults:[Note]?
    private var selectedCellIndexPath:NSIndexPath?
    private var selectedNote:Note?
    
    private lazy var prototypeCell:ListViewCell = { [unowned self] in
        var lazy = self.tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.ListViewCell) as! ListViewCell
        return lazy
    }()
    
    
    //MARK: IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!{
        didSet{
            searchBar.delegate = self
        }
    }
    
    
    //MARK: IBActions
    @IBAction func helpButtonHandler(sender: UIBarButtonItem) {
        helpView.show(view.superview!.frame)
    }
    

    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func setUpCloseSearchTap(){
            let tap = UITapGestureRecognizer(target: self, action: Constants.Selectors.CloseSearch)
            tap.delegate = self
            view.addGestureRecognizer(tap)
        }

        tableView.estimatedRowHeight = Constants.TableView.EstimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        
        setUpCloseSearchTap()
        initializeFetchedResultsController()
    }
    

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        helpView.hide()
        reset()
    }
    
    
    // MARK: UITapGestureRecognizers
    func closeSearch(sender:UITapGestureRecognizer?=nil){
        searchBar.resignFirstResponder()
    }
    
    // MARK: Overrides
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.Segues.EditNote{
            var destination = segue.destinationViewController
            
            if let navController = destination as? UINavigationController {
                destination = navController.visibleViewController!
            }
            if let controller = destination as? CreateNoteViewController{
                controller.note = selectedNote
            }
        }
    }

    // ignore taps for tableview so we don't override didSelectRowAtIndexPath
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return !(touch.view is UITableViewCell) && !(touch.view?.superview is UITableViewCell) && !(touch.view?.superview?.superview is UITableViewCell)
    }
    
    // MARK: Private Methods
    func cellSelected(sender:UILongPressGestureRecognizer){
        if sender.state == .Began {
            
            if let cell = sender.view as? ListViewCell{
                selectedNote = cell.note
            }

            performSegueWithIdentifier(Constants.Segues.EditNote, sender: self)
        }
    }
    
    private func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: Entities.Note)
        request.sortDescriptors = [NSSortDescriptor(key: Note.Constants.Properties.Date, ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: RequestManager.appDelegate.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    private func getNoteAtIndexPath(indexPath:NSIndexPath)->Note?{
        var note:Note?
        
        if filteredResults != nil && filteredResults?.count > indexPath.row {
                note = filteredResults![indexPath.row]
        } else {
            note = fetchedResultsController.objectAtIndexPath(indexPath) as? Note
        }
        
        return note
    }
    
    private func reset(){
        filteredResults = nil
        tableView.reloadData()
        searchBar.text = ""
        
        resetSelectedCell()
        tableView.beginUpdates()
        tableView.endUpdates()

    }
    
    private func resetSelectedCell(){
        if selectedCellIndexPath != nil {
            if let cell = tableView.cellForRowAtIndexPath(selectedCellIndexPath!) as? ListViewCell{
                selectedCellIndexPath = nil
                cell.resetConstraints()
            }
        }

    }
    
    // MARK: UIHelpView Protocol
    func helpViewDidHide() {
        tableView.scrollEnabled = true
    }
    func helpViewDidShow() {
        tableView.scrollEnabled = false
    }
    
    // MARK: ListViewCell Protocol
    func listViewCellLinkClicked(data: String) {
        searchBar(searchBar, textDidChange: data)
        searchBar.text = data
    }
    
    func listViewCellSelected(cell:ListViewCell) {
        selectedNote = cell.note
        performSegueWithIdentifier(Constants.Segues.EditNote, sender: self)
    }
    

    // MARK: NSFetchedResultsController Protocol
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        resetSelectedCell()
        
        switch type {
        case .Insert:
            if(newIndexPath != nil) {
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                tableView.endUpdates()
                tableView.reloadData()
                
                if let _ = tableView.cellForRowAtIndexPath(newIndexPath!) {
                    tableView.scrollToRowAtIndexPath(newIndexPath!, atScrollPosition: .None, animated: false)
                }
                
            }
        case .Delete:
            if indexPath != nil{
                filteredResults = nil
                
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.endUpdates()
                
                if let text = searchBar.text{
                    if !text.isEmpty{
                        listViewCellLinkClicked(text)
                    }
                }
            }
        case .Move:
            if(newIndexPath != nil) {
                tableView.reloadData()
                if let _ = tableView.cellForRowAtIndexPath(newIndexPath!) {
                    tableView.scrollToRowAtIndexPath(newIndexPath!, atScrollPosition: .None, animated: false)
                }
            }
            break
        case .Update:
            break
        }

    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    // MARK: SearchBar Protocol
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredResults = nil

        if searchText != "" {
            
            // search by caption
            var uniqueNotes = RequestManager.getNotes(searchText) ?? [Note]()

            // get tags that match the search
            let tags = RequestManager.getTags(searchText.lowercaseString.stringByReplacingOccurrencesOfString("#", withString: ""))
            
            // get notes from tags [[Note]] (array of array)
            let collectionsOfNotes = tags?.map(){ $0.notes?.map(){ $0 as! Note } }
            
            if let noteCollections = collectionsOfNotes as? [[Note]]{
                var notes = [Note]()

                // condenese into 1 array
                for noteCollection in noteCollections {
                    notes += noteCollection
                }
                
                // remove duplicates
                for note in notes{
                    if !uniqueNotes.contains(note){
                        uniqueNotes += [note]
                    }
                }
            }
            
            filteredResults = uniqueNotes
        }
        tableView.reloadData()
        resetSelectedCell()
        tableView.beginUpdates()
        tableView.endUpdates()
        
        tableView.scrollRectToVisible(CGRectZero, animated: false)

    }

    // MARK: TableView Protocol
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if filteredResults != nil {
            return 1
        } else {
            return fetchedResultsController.sections?.count ?? 0
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.ListViewCell, forIndexPath: indexPath) as! ListViewCell
        
        if let note = getNoteAtIndexPath(indexPath){

            cell.note = note
            cell.selectionStyle = .None;
            cell.resetConstraints()
            cell.delegate = self
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            if let note = fetchedResultsController.objectAtIndexPath(indexPath) as? Note{
                RequestManager.deleteNote(note)
            }
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ListViewCell{
            cell.resetConstraints()
            selectedCellIndexPath = nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath != selectedCellIndexPath, let cell = tableView.cellForRowAtIndexPath(indexPath) as? ListViewCell{
            
            UIView.animateWithDuration(0.25, animations: { [weak self] in
                cell.increaseImageSize(Constants.TableView.ImageMultiplier)
                self?.view.layoutIfNeeded()
                })
        }
        selectedCellIndexPath = indexPath
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.scrollToRowAtIndexPath(selectedCellIndexPath!, atScrollPosition: .None, animated: false)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if selectedCellIndexPath == indexPath {
            return Constants.TableView.SelectedRowHeight
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredResults != nil {
            return filteredResults?.count ?? 0
        } else {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
    }


    // MARK: ScrollView Protocol
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if selectedCellIndexPath != nil{
            if let cell = tableView.cellForRowAtIndexPath(selectedCellIndexPath!) as? ListViewCell{
                cell.resetConstraints()
                selectedCellIndexPath = nil
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }

    }
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        closeSearch()
    }
    
}


