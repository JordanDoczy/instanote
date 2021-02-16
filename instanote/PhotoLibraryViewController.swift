//
//  PhotoLibraryViewController.swift
//  instanote
//
//  Created by Jordan Doczy on 12/4/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

class PhotoLibraryViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout  {
    
    // MARK: Private Members
    fileprivate struct Constants {
        struct CellIdentifiers{
            static let PhotoCell = "Photo Cell"
        }
        struct Segues {
            static let CreateNote = "Create Note"
            static let UnwindToCreateNote = "Unwind To Create Note"
            static let UnwindToHome = "Unwind To Home"
        }
    }
    
    fileprivate var isUnwind:Bool{
        return !(presentingViewController is MainTabBarController)
    }
    fileprivate var results:PHFetchResult<AnyObject>!
    fileprivate var selectedImage:UIImage?
    
    
    // MARK: IBActions
    @IBAction func close(_ sender: UIBarButtonItem) {
        if isUnwind {
            performSegue(withIdentifier: Constants.Segues.UnwindToCreateNote, sender: self)
        } else {
            performSegue(withIdentifier: Constants.Segues.UnwindToHome, sender: self)
        }
    }
    

    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
        switch(PHPhotoLibrary.authorizationStatus()){
        case .authorized, .limited:
            loadData()
        case .denied:
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] (status) -> Void in
                if status == PHAuthorizationStatus.authorized {
                    DispatchQueue.main.async{ [weak self] in
                        self?.loadData()
                    }
                }
            }
        case .restricted:
            break
        @unknown default:
            break
        }
    }
    
    func loadData(){
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        results = PHAsset.fetchAssets(with: .image, options: options) as? PHFetchResult<AnyObject>
        if results.count > 0 {
            collectionView?.reloadData()
        }
    }
    
    // MARK: Overrides
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        
        if let navController = destination as? UINavigationController {
            destination = navController.visibleViewController!
        }

        if segue.identifier == Constants.Segues.CreateNote || segue.identifier == Constants.Segues.UnwindToCreateNote{
            if let controller = destination as? CreateNoteViewController{
                controller.image = selectedImage
            }
        }
    }
    
    
    // MARK: Collection View Protocol
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifiers.PhotoCell, for: indexPath) as! PhotoCell
        if let asset = results.object(at: indexPath.row) as? PHAsset{
            cell.asset = asset
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let asset = results.object(at: indexPath.row) as? PHAsset{
         
            let options = PHImageRequestOptions()
            options.resizeMode = .exact
            options.deliveryMode = .highQualityFormat
            
            let manager = PHImageManager.default()
            manager.requestImage(for: asset, targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFit, options: options) { [unowned self] (image, _) in
                    self.selectedImage = image
                    if self.isUnwind {
                        self.performSegue(withIdentifier: Constants.Segues.UnwindToCreateNote, sender: self)
                    } else {
                        self.performSegue(withIdentifier: Constants.Segues.CreateNote, sender: self)
                    }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if results != nil {
            return results.count
        }
        return 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    // MARK: CollectionViewLayout Protocol
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/4.05 , height: collectionView.frame.size.width/4.05)
    }

    
    
    
    
}
