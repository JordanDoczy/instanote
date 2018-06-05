//
//  ListViewController.swift
//  instanote
//
//  Created by Jordan Doczy on 12/1/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class NotesViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, UIHelpViewDelegate, ListViewCellDelegate {
    
    // MARK: Private Members
    fileprivate struct Constants {
        struct CellIdentifiers{
            static let ListViewCell = "ListViewCell"
        }
        struct Selectors {
            static let CloseSearch:Selector = #selector(NotesViewController.closeSearch(_:))
            static let CellSelected:Selector = #selector(NotesViewController.cellSelected(_:))
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
    
    fileprivate lazy var helpView: HelpView = { [unowned self] in
       let helpView = HelpView()
        self.view.addSubview(helpView)
        helpView.delegate = self
        return helpView
    }()
    fileprivate var fetchImageOperationQueue:OperationQueue = OperationQueue()
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    fileprivate var filteredResults:[Note]?
    fileprivate var selectedCellIndexPath:IndexPath?
    fileprivate var selectedNote:Note?
    
    fileprivate lazy var prototypeCell: ListViewCell = { [unowned self] in
        var prototypeCell = self.tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.ListViewCell) as! ListViewCell
        return prototypeCell
    }()
    
    
    //MARK: IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!{
        didSet{
            searchBar.delegate = self
        }
    }
    
    
    //MARK: IBActions
    @IBAction func helpButtonHandler(_ sender: UIBarButtonItem) {
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
    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        helpView.hide()
        reset()
    }
    
    
    // MARK: UITapGestureRecognizers
    @objc func closeSearch(_ sender:UITapGestureRecognizer?=nil){
        searchBar.resignFirstResponder()
    }
    
    // MARK: Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.EditNote{
            var destination = segue.destination
            
            if let navController = destination as? UINavigationController {
                destination = navController.visibleViewController!
            }
            if let controller = destination as? CreateNoteViewController{
                controller.note = selectedNote
            }
        }
    }

    // ignore taps for tableview so we don't override didSelectRowAtIndexPath
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UITableViewCell) && !(touch.view?.superview is UITableViewCell) && !(touch.view?.superview?.superview is UITableViewCell)
    }
    
    // MARK: Private Methods
    @objc func cellSelected(_ sender:UILongPressGestureRecognizer){
        if sender.state == .began {
            
            if let cell = sender.view as? ListViewCell{
                selectedNote = cell.note
            }

            performSegue(withIdentifier: Constants.Segues.EditNote, sender: self)
        }
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

    fileprivate func getNoteAtIndexPath(_ indexPath:IndexPath)->Note?{
        var note:Note?
        
        if filteredResults != nil && filteredResults?.count > indexPath.row {
                note = filteredResults![indexPath.row]
        } else {
            note = fetchedResultsController.object(at: indexPath) as? Note
        }
        
        return note
    }
    
    fileprivate func reset(){
        filteredResults = nil
        tableView.reloadData()
        searchBar.text = ""
        
        resetSelectedCell()
        tableView.beginUpdates()
        tableView.endUpdates()

    }
    
    fileprivate func resetSelectedCell(){
        if selectedCellIndexPath != nil {
            if let cell = tableView.cellForRow(at: selectedCellIndexPath!) as? ListViewCell{
                selectedCellIndexPath = nil
                cell.resetConstraints()
            }
        }

    }
    
    // MARK: UIHelpView Protocol
    func helpViewDidHide() {
        tableView.isScrollEnabled = true
    }
    func helpViewDidShow() {
        tableView.isScrollEnabled = false
    }
    
    // MARK: ListViewCell Protocol
    func listViewCellLinkClicked(_ data: String) {
        searchBar(searchBar, textDidChange: data)
        searchBar.text = data
    }
    
    func listViewCellSelected(_ cell:ListViewCell) {
        selectedNote = cell.note
        performSegue(withIdentifier: Constants.Segues.EditNote, sender: self)
    }
    

    // MARK: NSFetchedResultsController Protocol
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        resetSelectedCell()
        
        switch type {
        case .insert:
            if(newIndexPath != nil) {
                tableView.beginUpdates()
                tableView.insertRows(at: [newIndexPath!], with: .fade)
                tableView.endUpdates()
                tableView.reloadData()
                
                if let _ = tableView.cellForRow(at: newIndexPath!) {
                    tableView.scrollToRow(at: newIndexPath!, at: .none, animated: false)
                }
                
            }
        case .delete:
            if indexPath != nil{
                filteredResults = nil
                
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.endUpdates()
                
                if let text = searchBar.text{
                    if !text.isEmpty{
                        listViewCellLinkClicked(text)
                    }
                }
            }
        case .move:
            if(newIndexPath != nil) {
                tableView.reloadData()
                if let _ = tableView.cellForRow(at: newIndexPath!) {
                    tableView.scrollToRow(at: newIndexPath!, at: .none, animated: false)
                }
            }
            break
        case .update:
            break
        }

    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    // MARK: SearchBar Protocol
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredResults = nil

        if searchText != "" {
            
            // search by caption
            var uniqueNotes = RequestManager.getNotes(searchText) ?? [Note]()

            // get tags that match the search
            let tags = RequestManager.getTags(searchText.lowercased().replacingOccurrences(of: "#", with: ""))
            
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
        
        tableView.scrollRectToVisible(CGRect.zero, animated: false)

    }

    // MARK: TableView Protocol
    override func numberOfSections(in tableView: UITableView) -> Int {
        if filteredResults != nil {
            return 1
        } else {
            return fetchedResultsController.sections?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.ListViewCell, for: indexPath) as! ListViewCell
        
        if let note = getNoteAtIndexPath(indexPath){

            cell.note = note
            cell.selectionStyle = .none;
            cell.resetConstraints()
            cell.delegate = self
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if let note = fetchedResultsController.object(at: indexPath) as? Note{
                RequestManager.deleteNote(note)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ListViewCell{
            cell.resetConstraints()
            selectedCellIndexPath = nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath != selectedCellIndexPath, let cell = tableView.cellForRow(at: indexPath) as? ListViewCell{
            
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                cell.increaseImageSize(Constants.TableView.ImageMultiplier)
                self?.view.layoutIfNeeded()
                })
        }
        selectedCellIndexPath = indexPath
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.scrollToRow(at: selectedCellIndexPath!, at: .none, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedCellIndexPath == indexPath {
            return Constants.TableView.SelectedRowHeight
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredResults != nil {
            return filteredResults?.count ?? 0
        } else {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
    }


    // MARK: ScrollView Protocol
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if selectedCellIndexPath != nil{
            if let cell = tableView.cellForRow(at: selectedCellIndexPath!) as? ListViewCell{
                cell.resetConstraints()
                selectedCellIndexPath = nil
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }

    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        closeSearch()
    }
    
}


