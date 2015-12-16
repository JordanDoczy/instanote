//
//  CameraViewController.swift
//  instanote
//
//  Created by Jordan Doczy on 11/29/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import MapKit
import MobileCoreServices

class CreateNoteViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, NoteDataSource, UIToggleViewDelegate  {
    
    // MARK: Public API
    var image:UIImage? {
        didSet{
            if image != nil {
                imageView.image = image
            }
        }
    }
    var note:Note? {
        didSet{
            title = Constants.Text.EditTitle
            if let coordinate = self.note?.coordinate {
                self.addPin(coordinate)
            }
        }
    }
    
    // MARK: Private Members
    private struct Constants {
        struct AnnotationIdentifiers{
            static let MapAnnotation = "MapAnnotation"
        }
        struct CellIdentifiers{
            static let AutoCompleteRowIdentifier:String = "AutoCompleteRowIdentifier"
        }
        struct Segues{
            static let ChoosePhoto = "Choose Photo"
            static let UnwindToChoosePhoto = "Unwind To Choose Photo"
            static let UnwindToHome = "Unwind To Home"
        }
        struct Selectors{
            static let CancelHandler:Selector = "cancelHandler:"
            static let CenterMap:Selector = "centerMap"
            static let DeleteHandler:Selector = "deleteHandler:"
            static let DropPin:Selector = "dropPin:"
            static let ForceSave:Selector = "forceSave"
            static let KeyboardWillShow:Selector = "keyboardWillShow:"
        }
        struct Text{
            static let PlaceholderText = "Write a caption"
            static let EditTitle = "Edit Note"
        }
    }

    private var annotation:MapAnnotation?
    private var attemptToSave:Bool = false
    private var autoCompleteDataSource = [String]()
    private var forceSaveTimer:NSTimer = NSTimer()
    private lazy var imageView:UIImageView = { [unowned self] in
       let lazy = UIImageView()
        lazy.contentMode = .ScaleAspectFill;
        lazy.clipsToBounds = true
        
        if self.note?.photo != nil {
            if self.note?.photo == Assets.SampleImage || self.note?.photo == Assets.DefaultImage{
                lazy.image = UIImage(named: self.note!.photo!)
            }
            else {
                UIImage.fetchImage(NSURL(string: self.note!.photo!)!) { image, response in
                    lazy.image = image
                }
            }
        }
        return lazy
    }()
    private var isEditMode:Bool{
        return note != nil
    }
    private lazy var locationManager:CLLocationManager = { [unowned self] in
        let lazy = CLLocationManager()
        lazy.delegate = self
        lazy.desiredAccuracy = kCLLocationAccuracyBest
        return lazy
    }()
    private lazy var mapView:MKMapView = {
        let press = UILongPressGestureRecognizer(target: self, action: Constants.Selectors.DropPin)
        press.minimumPressDuration = 0.5

        let lazy = MKMapView()
        lazy.userInteractionEnabled = true
        lazy.userLocation.title = ""
        lazy.delegate = self
        lazy.addGestureRecognizer(press)

        return lazy
    }()
    private lazy var overlay:Overlay = { [unowned self] in
        let lazy = Overlay()
        lazy.effect = UIBlurEffect(style: .Light)
        lazy.frame = self.view.frame
        lazy.hidden = true
        return lazy
    }()
    private var rangeToHash = NSRange()
    private var tagSearch:String = ""
    

    
    // MARK: IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! { didSet { activityIndicator.stopAnimating() }}
    @IBOutlet weak var autoCompleteBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var autoCompleteTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var autoCompleteTableView: UITableView! {
        didSet{
            autoCompleteTableView.delegate = self
            autoCompleteTableView.dataSource = self
            autoCompleteTableView.scrollEnabled = true
            autoCompleteTableView.hidden = true
            autoCompleteTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.AutoCompleteRowIdentifier)
        }
    }
    @IBOutlet weak var cameraButton: UIButton! {
        didSet{
            cameraButton.backgroundColor = Colors.PrimaryTransparent
            cameraButton.hidden = true
        }
    }
    @IBOutlet weak var captionTextView: UITextView!{
        didSet{
            captionTextView.delegate = self
            captionTextView.text = note?.caption ?? Constants.Text.PlaceholderText
            captionTextView.textColor = isEditMode ? Colors.Text : UIColor.lightGrayColor()
            captionTextView.textContainerInset = UIEdgeInsetsMake(10,10,0,10);
            captionTextView.layer.borderColor = Colors.LightGray.CGColor
            captionTextView.layer.borderWidth = 1
            captionTextView.userInteractionEnabled = true
        }
    }

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteModal: UIView!
    @IBOutlet weak var deleteModalLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var toggleView: UIToggleView! {
        didSet{
            func createExpandIndicator()->UIView{
                let view = UIImageView(image: UIImage(named: Assets.Expand))
                view.image = view.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                view.frame.size = CGSize(width: 20, height: 20)
                view.tintColor = UIColor.whiteColor()
                view.backgroundColor = Colors.PrimaryTransparent
                return view
            }
            
            toggleView.delegate = self
            toggleView.expandIndicator = createExpandIndicator()
            
            if isEditMode {
                toggleView.primaryView = imageView
                toggleView.secondaryView = mapView
                cameraButton.hidden = false
            } else {
                toggleView.primaryView = mapView
                toggleView.secondaryView = imageView
                cameraButton.hidden = true
            }
            
            mapView.scrollEnabled = mapView == toggleView.primaryView
        }
    }
    
    
    // MARK: IBActions
    @IBAction func createNote(segue:UIStoryboardSegue) {}

    @IBAction func saveHandler(sender: UIBarButtonItem?=nil) {
        attemptSave()
    }
    
    @IBAction func deleteHandler(sender: UIButton) {
        showDeleteModal()
    }
    
    @IBAction func cancelHandler(sender: UIButton?=nil) {
        deleteModalPeek()
    }

    @IBAction func cameraHandler(sender: UIButton) {
        
        if isEditMode{
            performSegueWithIdentifier(Constants.Segues.ChoosePhoto, sender: self)
        } else{
            performSegueWithIdentifier(Constants.Segues.UnwindToChoosePhoto, sender: self)
        }
        
    }
    
    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Constants.Selectors.KeyboardWillShow, name: UIKeyboardWillShowNotification, object: nil)
        
        if isEditMode {
            deleteModalPeek()
            overlay.show()
            overlay.hidden = true
            view.addSubview(overlay)
        } else {
            hideDeleteModal()
        }
        
        hideAutoComplete()
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        dismissButton.image = isEditMode ? UIImage(named: Assets.Close) : UIImage(named: Assets.Back)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        forceSaveTimer.invalidate()
    }

    
    // MARK: Overrides
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        captionTextView.resignFirstResponder()
    }
    
    // MARK: Gesture Recognizers
    func dropPin(sender:UILongPressGestureRecognizer){
        let coordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)

        if sender.state == UIGestureRecognizerState.Began {
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse && annotation == nil {
                addPin(coordinate)
            }
            else if annotation != nil {
                movePin(coordinate)
            }
        }
    }
    
    
    // MARK: Show / Hide Methods
    func deleteModalPeek(){
        if !overlay.hidden {
            overlay.hide()
        }
        UIView.animateWithDuration(0.25) { [unowned self] in
            self.deleteModalLayoutConstraint.constant = self.deleteButton.frame.height - self.deleteModal.frame.height
            self.view.layoutIfNeeded()
        }
    }
    
    func hideDeleteModal(){
        self.deleteModalLayoutConstraint.constant = -deleteModal.frame.height
    }
    
    func showDeleteModal(){
        if overlay.hidden {
            overlay.show()
            view.bringSubviewToFront(deleteModal)
            UIView.animateWithDuration(0.25, animations: { [unowned self] in
                self.deleteModalLayoutConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        } else {
            if isEditMode {
                RequestManager.deleteNote(note!)
                performSegueWithIdentifier(Constants.Segues.UnwindToHome, sender: self)
            }
        }
    }
    
    func hideAutoComplete(){
        if !autoCompleteTableView.hidden {
            UIView.animateWithDuration(0.1,
                animations: { [unowned self] in
                    self.autoCompleteTopLayoutConstraint.constant = self.autoCompleteTableView.frame.height
                    self.view.layoutIfNeeded()
                },
                completion: { [unowned self] success in
                    self.autoCompleteTableView.hidden = true
                })
        }
    }
    
    func showAutoComplete(){
        autoCompleteTableView.hidden = false
        UIView.animateWithDuration(0.1, animations: { [unowned self] in
            self.autoCompleteTopLayoutConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillShow(notification:NSNotification){
        if let rect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
            let keyboardRect = view.convertRect(rect, fromView: nil)
            autoCompleteBottomLayoutConstraint.constant = keyboardRect.height
        }
    }
    


    // MARK: Save Methods
    private func attemptSave(){
        activityIndicator.startAnimating()
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse && annotation == nil {
            attemptToSave = true
            locationManager.requestLocation()
            forceSaveTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Constants.Selectors.ForceSave, userInfo: nil, repeats: false)
        }
        else {
            save()
        }
    }
    
    
    // not private so forceTimer can call
    func forceSave(){
        if attemptToSave {
            save()
        }
    }
    
    private func save(){
        func compareImages(image1:UIImage, image2:UIImage)->Bool{
            let imgData1 = UIImagePNGRepresentation(image1)
            let imgData2 = UIImagePNGRepresentation(image2)
            return imgData1!.isEqualToData(imgData2!)
        }
        
        forceSaveTimer.invalidate()
        attemptToSave = false
        
        let photo:String? = image != nil ? saveImage(image!) : note?.photo != nil ? note!.photo : nil
        
        let text = captionTextView.text != Constants.Text.PlaceholderText ? captionTextView.text : ""
        if isEditMode {
            RequestManager.updateNote(&note!, caption: text, photo: photo, location: annotation?.coordinate)
        } else {
            RequestManager.createNote(text, photo: photo, location: annotation?.coordinate)
        }
        RequestManager.save()
        
        performSegueWithIdentifier(Constants.Segues.UnwindToHome, sender: self)
    }
    
    private func saveImage(image:UIImage)->String?{
        
        if let imageData = UIImageJPEGRepresentation(image, 1.0){
            if let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first{
                let fileName = "\(NSDate.timeIntervalSinceReferenceDate()).jpg"
                let imageURL = documentsURL.URLByAppendingPathComponent(fileName)
                imageData.writeToURL(imageURL, atomically: true)
                return imageURL.absoluteString
            }
        }
        return nil
    }
    
    
    // MARK: LocationManager Protocol
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
            locationManager.requestLocation()
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //print(error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if annotation == nil, let coordinate = locations.first?.coordinate {
            addPin(coordinate)
        }
        if attemptToSave {
            save()
        }
    }
    

    // MARK: MapView Protocol
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isEqual(mapView.userLocation){ return nil }
        
        let view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationIdentifiers.MapAnnotation) ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationIdentifiers.MapAnnotation) as MKPinAnnotationView
        
        view.annotation = annotation
        view.draggable = mapView == toggleView.primaryView
        view.userInteractionEnabled = true
        (view as! MKPinAnnotationView).animatesDrop = true

        return view
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        performSelector(Constants.Selectors.CenterMap, withObject: nil, afterDelay: 0.5)
    }
    
    func addPin(coordinate:CLLocationCoordinate2D){
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        
        mapView.setRegion(region, animated: false)
        
        annotation = MapAnnotation()
        annotation!.coordinate = coordinate
        mapView.addAnnotation(annotation!)
    }
    
    func movePin(coordinate:CLLocationCoordinate2D){
        if annotation != nil{
            annotation!.coordinate = coordinate
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation!)
        }
    }
    
    func centerMap(){
        
        let coordinate = annotation?.coordinate ?? mapView.annotations.first?.coordinate
        
        if coordinate != nil{
            mapView.setCenterCoordinate(coordinate!, animated:true)
        }
        
    }
    
    // MARK: TableView Protocol
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.AutoCompleteRowIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = autoCompleteDataSource[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if let selectedText = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text{

            var range = NSRange()
            range.location = rangeToHash.location.successor()
            range.length = rangeToHash.length.predecessor()
            
            captionTextView.text = (captionTextView.text as NSString).stringByReplacingCharactersInRange(range, withString: selectedText)

            hideAutoComplete()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoCompleteDataSource.count
    }
    

    // MARK: TextView Protocol
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = Colors.Text
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.Text.PlaceholderText
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        func checkForMatch() ->Bool{
            autoCompleteDataSource.removeAll(keepCapacity: false)
            autoCompleteTableView.reloadData()

            if textView.text != nil {
                let changedText = (textView.text! as NSString).stringByReplacingCharactersInRange(range, withString: text)
                
                var rangeFromStart = NSRange()
                rangeFromStart.location = 0
                rangeFromStart.length = range.location
                
                let hashRange = (changedText as NSString).rangeOfString("#", options: .BackwardsSearch, range: rangeFromStart, locale: nil)
                
                if hashRange.location < changedText.characters.count{
                    
                    rangeToHash = NSRange()
                    rangeToHash.location = hashRange.location
                    rangeToHash.length = range.location - hashRange.location + text.characters.count

                    let whiteSpaceRange = (changedText as NSString).rangeOfString("[^\\w#]", options: .RegularExpressionSearch, range: rangeToHash, locale: nil)
                    
                    if whiteSpaceRange.location > changedText.characters.count{
                        tagSearch = (changedText as NSString).substringWithRange(rangeToHash)

                        if let tags = RequestManager.getTags(tagSearch.substringFromIndex(tagSearch.startIndex.successor())){
                            autoCompleteDataSource = tags.map(){$0.name!}
                            autoCompleteTableView.reloadData()
                        }
                    }
                }
            }
            
            if autoCompleteDataSource.count <= 0 {
                hideAutoComplete()
            } else {
                showAutoComplete()
            }
            
            return autoCompleteDataSource.count > 0
            
        }
        
        checkForMatch()
        return true
    }
    
    
    // MARK: UIToggleView Protocol
    func toggleViewDidToggle(){
        
        mapView.scrollEnabled = (mapView == toggleView.primaryView)
        if annotation != nil {
            mapView.setCenterCoordinate(annotation!.coordinate, animated: true)
            if let annotationView = mapView.viewForAnnotation(annotation!){
                annotationView.draggable = mapView.scrollEnabled
            }
        }
        
        cameraButton.hidden = toggleView.primaryView != imageView

        if !cameraButton.hidden {
            cameraButton.frame.origin.y -= cameraButton.frame.height
            
            UIView.animateWithDuration(0.30, delay: 0.07, options: .CurveEaseOut,
                animations: { [unowned self] in
                    self.cameraButton.frame.origin.y += self.cameraButton.frame.height
                },
                completion: nil)
        }
    }
    
    func toggleViewWillToggle(){
        cameraButton.hidden = true
    }

}

class Overlay : UIVisualEffectView {
    

    func show(completion:((success:Bool)->Void)?=nil){
        effect = nil
        hidden = false
        
        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseOut,
            animations: { [unowned self] in
                self.effect = UIBlurEffect(style: .Light)
            },
            completion: { success in
                if completion != nil {
                    completion!(success:success)
                }
            }
        )
    }
    
    func hide(completion:((success:Bool)->Void)?=nil){
        hidden = false
        
        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseOut,
            animations: { [unowned self] in
                self.effect = nil
            },
            completion: { [unowned self] success in
                self.hidden = true
                if completion != nil {
                    completion!(success:success)
                }
            }
        )
        
    }
    
}


