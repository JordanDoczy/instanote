//
//  CGShaperLayerExtension.swift
//  instanote
//
//  Created by Jordan Doczy on 12/7/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit



extension CAShapeLayer{
    
    enum BorderType : UInt32 {
        case Left
        case Right
        case Top
        case Bottom
        case All
    }
    
    static func getLine(rect:CGSize, borderOptions:[BorderType]?=[BorderType.All], color:CGColor?=nil, lineWidth:CGFloat?=nil)->CAShapeLayer{
        let path = UIBezierPath()
        
        if borderOptions!.contains(BorderType.Top) || borderOptions!.contains(BorderType.All){
            path.moveToPoint(CGPoint(x:0, y:0))
            path.addLineToPoint(CGPoint(x: rect.width, y: 0))
        }
        if borderOptions!.contains(BorderType.Right) || borderOptions!.contains(BorderType.All){
            path.moveToPoint(CGPoint(x:rect.width, y:0))
            path.addLineToPoint(CGPoint(x: rect.width, y: rect.height))
            
        }
        if borderOptions!.contains(BorderType.Bottom) || borderOptions!.contains(BorderType.All){
            path.moveToPoint(CGPoint(x:rect.width, y:rect.height))
            path.addLineToPoint(CGPoint(x: 0, y: rect.height))
        }
        if borderOptions!.contains(BorderType.Left) || borderOptions!.contains(BorderType.All){
            path.moveToPoint(CGPoint(x:0, y:rect.height))
            path.addLineToPoint(CGPoint(x: 0, y: 0))
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = color ?? UIColor.blackColor().CGColor
        shapeLayer.lineWidth = lineWidth ?? 1.0
        
        return shapeLayer
    }
}


