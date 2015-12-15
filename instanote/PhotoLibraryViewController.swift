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
    private struct Constants {
        struct CellIdentifiers{
            static let PhotoCell = "Photo Cell"
        }
        struct Segues {
            static let CreateNote = "Create Note"
            static let UnwindToCreateNote = "Unwind To Create Note"
            static let UnwindToHome = "Unwind To Home"
        }
    }
    
    private var isUnwind:Bool{
        return !(presentingViewController is MainTabBarController)
    }
    private var results:PHFetchResult!
    private var selectedImage:UIImage?
    
    
    // MARK: IBActions
    @IBAction func close(sender: UIBarButtonItem) {
        if isUnwind {
            performSegueWithIdentifier(Constants.Segues.UnwindToCreateNote, sender: self)
        } else {
            performSegueWithIdentifier(Constants.Segues.UnwindToHome, sender: self)
        }
    }
    

    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
        switch(PHPhotoLibrary.authorizationStatus()){
        case .Authorized:
            loadData()
        case .Denied:
            break
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization { [unowned self] (status) -> Void in
                if status == PHAuthorizationStatus.Authorized {
                    dispatch_async(dispatch_get_main_queue()){ [unowned self] in
                        self.loadData()
                    }
                }
            }
        case .Restricted:
            break
        }
    }
    
    func loadData(){
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        results = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        if results.count > 0 {
            collectionView?.reloadData()
        }
    }
    
    // MARK: Overrides
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController
        
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
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CellIdentifiers.PhotoCell, forIndexPath: indexPath) as! PhotoCell
        if let asset = results.objectAtIndex(indexPath.row) as? PHAsset{
            cell.asset = asset
        }
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let asset = results.objectAtIndex(indexPath.row) as? PHAsset{
         
            let options = PHImageRequestOptions()
            options.resizeMode = .Exact
            options.deliveryMode = .HighQualityFormat
            
            let manager = PHImageManager.defaultManager()
            manager.requestImageForAsset(asset, targetSize: CGSize(width: 1000, height: 1000), contentMode: .AspectFit, options: options) { [unowned self] (image, _) in
                    self.selectedImage = image
                    if self.isUnwind {
                        self.performSegueWithIdentifier(Constants.Segues.UnwindToCreateNote, sender: self)
                    } else {
                        self.performSegueWithIdentifier(Constants.Segues.CreateNote, sender: self)
                    }
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if results != nil {
            return results.count
        }
        return 0
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    // MARK: CollectionViewLayout Protocol
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.size.width/4.05 , collectionView.frame.size.width/4.05)
    }

    
    
    
    
}
