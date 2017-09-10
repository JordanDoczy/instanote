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
        case left
        case right
        case top
        case bottom
        case all
    }
    
    static func getLine(_ rect:CGSize, borderOptions:[BorderType]?=[BorderType.all], color:CGColor?=nil, lineWidth:CGFloat?=nil)->CAShapeLayer{
        let path = UIBezierPath()
        
        if borderOptions!.contains(BorderType.top) || borderOptions!.contains(BorderType.all){
            path.move(to: CGPoint(x:0, y:0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
        }
        if borderOptions!.contains(BorderType.right) || borderOptions!.contains(BorderType.all){
            path.move(to: CGPoint(x:rect.width, y:0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            
        }
        if borderOptions!.contains(BorderType.bottom) || borderOptions!.contains(BorderType.all){
            path.move(to: CGPoint(x:rect.width, y:rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
        if borderOptions!.contains(BorderType.left) || borderOptions!.contains(BorderType.all){
            path.move(to: CGPoint(x:0, y:rect.height))
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color ?? UIColor.black.cgColor
        shapeLayer.lineWidth = lineWidth ?? 1.0
        
        return shapeLayer
    }
}


