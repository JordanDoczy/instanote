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
    fileprivate struct Constants {
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
            static let CenterMap:Selector = #selector(CreateNoteViewController.centerMap)
            static let DropPin:Selector = #selector(CreateNoteViewController.dropPin(_:))
            static let ForceSave:Selector = #selector(CreateNoteViewController.forceSave)
            static let KeyboardWillShow:Selector = #selector(CreateNoteViewController.keyboardWillShow(_:))
        }
        struct Text{
            static let PlaceholderText = "Write a caption"
            static let EditTitle = "Edit Note"
        }
    }

    fileprivate var annotation:MapAnnotation?
    fileprivate var attemptToSave:Bool = false
    fileprivate var autoCompleteDataSource = [String]()
    fileprivate var forceSaveTimer:Timer = Timer()
    fileprivate lazy var imageView:UIImageView = { [unowned self] in
       let lazy = UIImageView()
        lazy.contentMode = .scaleAspectFill;
        lazy.clipsToBounds = true
        
        if self.note?.imagePath != nil {
            if self.note?.imagePath == Assets.SampleImage || self.note?.photo == Assets.DefaultImage{
                lazy.image = UIImage(named: self.note!.imagePath!)
            }
            else {
                _ = UIImage.fetchImage(URL(string: self.note!.imagePath!)!) { (image, _) in
                    lazy.image = image
                }
            }
        }
        return lazy
    }()
    fileprivate var isEditMode:Bool{
        return note != nil
    }
    fileprivate lazy var locationManager:CLLocationManager = { [unowned self] in
        let lazy = CLLocationManager()
        lazy.delegate = self
        lazy.desiredAccuracy = kCLLocationAccuracyBest
        return lazy
    }()
    fileprivate lazy var mapView:MKMapView = {
        let press = UILongPressGestureRecognizer(target: self, action: Constants.Selectors.DropPin)
        press.minimumPressDuration = 0.5

        let lazy = MKMapView()
        lazy.isUserInteractionEnabled = true
        lazy.userLocation.title = ""
        lazy.delegate = self
        lazy.addGestureRecognizer(press)

        return lazy
    }()
    fileprivate lazy var overlay:Overlay = { [unowned self] in
        let lazy = Overlay()
        lazy.effect = UIBlurEffect(style: .light)
        lazy.frame = self.view.frame
        lazy.isHidden = true
        return lazy
    }()
    fileprivate var rangeToHash = NSRange()
    fileprivate var tagSearch:String = ""
    

    
    // MARK: IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! { didSet { activityIndicator.stopAnimating() }}
    @IBOutlet weak var autoCompleteBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var autoCompleteTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var autoCompleteTableView: UITableView! {
        didSet{
            autoCompleteTableView.delegate = self
            autoCompleteTableView.dataSource = self
            autoCompleteTableView.isScrollEnabled = true
            autoCompleteTableView.isHidden = true
            autoCompleteTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.AutoCompleteRowIdentifier)
        }
    }
    @IBOutlet weak var cameraButton: UIButton! {
        didSet{
            cameraButton.backgroundColor = Colors.PrimaryTransparent
            cameraButton.isHidden = true
        }
    }
    @IBOutlet weak var captionTextView: UITextView!{
        didSet{
            captionTextView.delegate = self
            captionTextView.text = note?.caption ?? Constants.Text.PlaceholderText
            captionTextView.textColor = isEditMode ? Colors.Text : UIColor.lightGray
            captionTextView.textContainerInset = UIEdgeInsets(top: 10,left: 10,bottom: 0,right: 10);
            captionTextView.layer.borderColor = Colors.LightGray.cgColor
            captionTextView.layer.borderWidth = 1
            captionTextView.isUserInteractionEnabled = true
        }
    }

    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var toggleView: UIToggleView! {
        didSet{
            func createExpandIndicator()->UIView{
                let view = UIImageView(image: UIImage(named: Assets.Expand))
                view.image = view.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                view.frame.size = CGSize(width: 20, height: 20)
                view.tintColor = UIColor.white
                view.backgroundColor = Colors.PrimaryTransparent
                return view
            }
            
            toggleView.delegate = self
            toggleView.expandIndicator = createExpandIndicator()
            
            if isEditMode {
                toggleView.primaryView = imageView
                toggleView.secondaryView = mapView
                cameraButton.isHidden = false
            } else {
                toggleView.primaryView = mapView
                toggleView.secondaryView = imageView
                cameraButton.isHidden = true
            }
            
            mapView.isScrollEnabled = mapView == toggleView.primaryView
        }
    }
    
    
    // MARK: IBActions
    @IBAction func createNote(_ segue:UIStoryboardSegue) {}

    @IBAction func onDeletePressed(_ sender: UIBarButtonItem) {
        showDeleteModal()
    }
    
    @IBAction func saveHandler(_ sender: UIBarButtonItem?=nil) {
        attemptSave()
    }
    
    @IBAction func cameraHandler(_ sender: UIButton) {
        
        if isEditMode{
            performSegue(withIdentifier: Constants.Segues.ChoosePhoto, sender: self)
        } else{
            performSegue(withIdentifier: Constants.Segues.UnwindToChoosePhoto, sender: self)
        }
        
    }
    
    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: Constants.Selectors.KeyboardWillShow,
            name: UIResponder.keyboardDidShowNotification, object: nil)

        if isEditMode {
            overlay.show()
            overlay.isHidden = true
            view.addSubview(overlay)
        } else {
            overlay.hide()
        }
        
        hideAutoComplete()
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dismissButton.image = isEditMode ? UIImage(named: Assets.Close) : UIImage(named: Assets.Back)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        forceSaveTimer.invalidate()
    }

    
    // MARK: Overrides
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        captionTextView.resignFirstResponder()
    }
    
    // MARK: Gesture Recognizers
    @objc func dropPin(_ sender:UILongPressGestureRecognizer){
        let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)

        if sender.state == UIGestureRecognizer.State.began {
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse && annotation == nil {
                addPin(coordinate)
            }
            else if annotation != nil {
                movePin(coordinate)
            }
        }
    }
    
    
    // MARK: Show / Hide Methods
    func showDeleteModal(){
        if overlay.isHidden {
            overlay.show()
            
            let alertView = UIAlertController()
            let delete = UIAlertAction(title: "Delete?", style: .destructive) { [weak self] _ in
                guard let note = self?.note else { return }
                RequestManager.deleteNote(note)
                self?.performSegue(withIdentifier: Constants.Segues.UnwindToHome, sender: self)
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                self?.overlay.hide()
            }
            
            alertView.addAction(delete)
            alertView.addAction(cancel)
            present(alertView, animated: true, completion: nil)
            
        }
    }
    
    func hideAutoComplete(){
        if !autoCompleteTableView.isHidden {
            UIView.animate(withDuration: 0.1,
                animations: { [unowned self] in
                    self.autoCompleteTopLayoutConstraint.constant = self.autoCompleteTableView.frame.height
                    self.view.layoutIfNeeded()
                },
                completion: { [unowned self] success in
                    self.autoCompleteTableView.isHidden = true
                })
        }
    }
    
    func showAutoComplete(){
        autoCompleteTableView.isHidden = false
        UIView.animate(withDuration: 0.1, animations: { [unowned self] in
            self.autoCompleteTopLayoutConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillShow(_ notification:Notification){
        if let rect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            let keyboardRect = view.convert(rect, from: nil)
            autoCompleteBottomLayoutConstraint.constant = keyboardRect.height
        }
    }
    


    // MARK: Save Methods
    fileprivate func attemptSave(){
        activityIndicator.startAnimating()
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse && annotation == nil {
            attemptToSave = true
            locationManager.requestLocation()
            forceSaveTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: Constants.Selectors.ForceSave, userInfo: nil, repeats: false)
        }
        else {
            save()
        }
    }
    
    
    // not private so forceTimer can call
    @objc func forceSave(){
        if attemptToSave {
            save()
        }
    }
    
    fileprivate func save(){
        func compareImages(_ image1:UIImage, image2:UIImage)->Bool{
            let imgData1 = image1.pngData()
            let imgData2 = image2.pngData()
            return (imgData1! == imgData2!)
        }
        
        forceSaveTimer.invalidate()
        attemptToSave = false
        
        let photo:String? = image != nil ? AppDelegate.sharedInstance().saveImage(image!) : note?.photo != nil ? note!.photo : nil
        
        let text = captionTextView.text != Constants.Text.PlaceholderText ? captionTextView.text : ""
        let location = annotation?.coordinate ?? CLLocationCoordinate2D()
        if isEditMode {
            RequestManager.updateNote(&note!, caption: text, photo: photo, location: location)
        } else {
            _ = RequestManager.createNote(text, photo: photo, location: location)
        }
        RequestManager.save()
        
        performSegue(withIdentifier: Constants.Segues.UnwindToHome, sender: self)
    }
    
        
    
    // MARK: LocationManager Protocol
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if annotation == nil, let coordinate = locations.first?.coordinate {
            addPin(coordinate)
        }
        if attemptToSave {
            save()
        }
    }
    

    // MARK: MapView Protocol
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isEqual(mapView.userLocation){ return nil }
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationIdentifiers.MapAnnotation) ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationIdentifiers.MapAnnotation) as MKPinAnnotationView
        
        view.annotation = annotation
        view.isDraggable = mapView == toggleView.primaryView
        view.isUserInteractionEnabled = true
        (view as! MKPinAnnotationView).animatesDrop = true

        return view
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        perform(Constants.Selectors.CenterMap, with: nil, afterDelay: 0.5)
    }
    
    func addPin(_ coordinate:CLLocationCoordinate2D){
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setRegion(region, animated: false)
        
        annotation = MapAnnotation()
        annotation!.coordinate = coordinate
        mapView.addAnnotation(annotation!)
    }
    
    func movePin(_ coordinate:CLLocationCoordinate2D){
        if annotation != nil{
            annotation!.coordinate = coordinate
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation!)
        }
    }
    
    @objc func centerMap(){
        
        let coordinate = annotation?.coordinate ?? mapView.annotations.first?.coordinate
        
        if coordinate != nil{
            mapView.setCenter(coordinate!, animated:true)
        }
        
    }
    
    // MARK: TableView Protocol
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.AutoCompleteRowIdentifier, for: indexPath) as UITableViewCell
        cell.textLabel!.text = autoCompleteDataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if let selectedText = tableView.cellForRow(at: indexPath)?.textLabel?.text{

            var range = NSRange()
            range.location = (rangeToHash.location + 1)
            range.length = (rangeToHash.length - 1)
            
            captionTextView.text = (captionTextView.text as NSString).replacingCharacters(in: range, with: selectedText)

            hideAutoComplete()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoCompleteDataSource.count
    }
    

    // MARK: TextView Protocol
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = Colors.Text
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.Text.PlaceholderText
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        func checkForMatch() ->Bool{
            autoCompleteDataSource.removeAll(keepingCapacity: false)
            autoCompleteTableView.reloadData()

            if textView.text != nil {
                let changedText = (textView.text! as NSString).replacingCharacters(in: range, with: text)
                
                var rangeFromStart = NSRange()
                rangeFromStart.location = 0
                rangeFromStart.length = range.location
                
                let hashRange = (changedText as NSString).range(of: "#", options: .backwards, range: rangeFromStart, locale: nil)
                
                if hashRange.location < changedText.count{
                    
                    rangeToHash = NSRange()
                    rangeToHash.location = hashRange.location
                    rangeToHash.length = range.location - hashRange.location + text.count

                    let whiteSpaceRange = (changedText as NSString).range(of: "[^\\w#]", options: .regularExpression, range: rangeToHash, locale: nil)
                    
                    if whiteSpaceRange.location > changedText.count{
                        tagSearch = (changedText as NSString).substring(with: rangeToHash)
                        let startIndex = tagSearch.index(after: tagSearch.startIndex)
                        if let tags = RequestManager.getTags(String(tagSearch[startIndex...])) {
                            autoCompleteDataSource = tags.map(){$0.name!}
                            autoCompleteTableView.reloadData()
                        }
                    }
                }
            }
            
            return autoCompleteDataSource.count > 0
            
        }
        
        if checkForMatch() {
            showAutoComplete()
        } else {
            hideAutoComplete()
        }
        
        return true
    }
    
    
    // MARK: UIToggleView Protocol
    func toggleViewDidToggle(){
        
        mapView.isScrollEnabled = (mapView == toggleView.primaryView)
        if annotation != nil {
            mapView.setCenter(annotation!.coordinate, animated: true)
            if let annotationView = mapView.view(for: annotation!){
                annotationView.isDraggable = mapView.isScrollEnabled
            }
        }
        
        cameraButton.isHidden = toggleView.primaryView != imageView

        if !cameraButton.isHidden {
            cameraButton.frame.origin.y -= cameraButton.frame.height
            
            UIView.animate(withDuration: 0.30, delay: 0.07, options: .curveEaseOut,
                animations: { [unowned self] in
                    self.cameraButton.frame.origin.y += self.cameraButton.frame.height
                },
                completion: nil)
        }
    }
    
    func toggleViewWillToggle(){
        cameraButton.isHidden = true
    }

}

class Overlay : UIVisualEffectView {
    

    func show(_ completion:((_ success:Bool)->Void)?=nil){
        effect = nil
        isHidden = false
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut,
            animations: { [unowned self] in
                self.effect = UIBlurEffect(style: .light)
            },
            completion: { success in
                if completion != nil {
                    completion!(success)
                }
            }
        )
    }
    
    func hide(_ completion:((_ success:Bool)->Void)?=nil){
        isHidden = false
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut,
            animations: { [unowned self] in
                self.effect = nil
            },
            completion: { [unowned self] success in
                self.isHidden = true
                if completion != nil {
                    completion!(success)
                }
            }
        )
        
    }
    
}


