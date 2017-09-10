//
//  MainTabBarController.swift
//  instanote
//
//  Created by Jordan Doczy on 12/3/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
import MapKit
import Photos

class MainTabBarController : UITabBarController, UITabBarControllerDelegate {
    
    struct Constants{
        struct Tabs{
            static let CreateNote = "Create Note"
            static let Photos = "Photos"
            static let Notes =  "Notes"
            static let Locations = "Locations"
        }
        
        struct Segues {
            static let ChoosePhoto = "Choose Photo"
        }
    }
    
    fileprivate var preloadCreateController = CreateNoteViewController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        if RequestManager.getNotes()?.count == 0 {
            RequestManager.createNote("Here is a sample note to get you started! Tap on the image to see more, or press and hold to edit the note. Notes can have #tags too!", photo: Assets.SampleImage, location: CLLocationCoordinate2D(latitude:37.7887171, longitude:-122.4053574))
            RequestManager.save()

        }
    }
    
    @IBAction func returnHome(_ segue:UIStoryboardSegue) {
        selectedIndex = previousSelectedIndex
    }
    
    var previousSelectedIndex = 0
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let title = item.title{
            if title == Constants.Tabs.CreateNote {
                performSegue(withIdentifier: Constants.Segues.ChoosePhoto, sender: self)
            }
            else{
                previousSelectedIndex = tabBar.items?.index(of: item) ?? 0
            }
        }
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        selectedIndex = previousSelectedIndex
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool{
        return !(viewController is CameraTabBarController)
    }
    

    
    
}
