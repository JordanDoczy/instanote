//
//  PhotoCollectionViewFlowLayout.swift
//  instanote
//
//  Created by Jordan Doczy on 12/1/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

class PhotoCollectionViewFlowLayout: UICollectionViewFlowLayout {

    let spacer:CGFloat = 4.0
    let numberOfColumns:CGFloat = 3.0
    
    override required init(){
        super.init()
        minimumLineSpacing = spacer
        minimumInteritemSpacing = spacer
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        minimumLineSpacing = spacer
        minimumInteritemSpacing = spacer
    }
    
    override var itemSize:CGSize {
        get{
            let itemWidth = (collectionView!.frame.width - (spacer*(numberOfColumns-1)))/(numberOfColumns)
            return CGSize(width: itemWidth, height: itemWidth)
        }
        set{
            self.itemSize = newValue
        }
    }

}
