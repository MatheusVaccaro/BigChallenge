//
//  InvertedCircle.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 02/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MKInvertedCircleOverlayRenderer: MKOverlayRenderer {
    
    var diameter: Double
    var fillColor: UIColor = UIColor.red
    var strokeColor: UIColor = UIColor.blue
    var lineWidth: CGFloat = 3
    
    init(circle: MKCircle) {
        diameter = circle.radius*2
        super.init(overlay: circle)
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let path = UIBezierPath(rect: CGRect(x: mapRect.origin.x,
                                             y: mapRect.origin.y,
                                             width: mapRect.size.width,
                                             height: mapRect.size.height))
        
        let radiusInMap = diameter * MKMapPointsPerMeterAtLatitude(overlay.coordinate.latitude)
        
        let mapSize: MKMapSize = MKMapSize(width: radiusInMap, height: radiusInMap)
        
        let regionOrigin = MKMapPointForCoordinate(overlay.coordinate)
        var regionRect: MKMapRect = MKMapRect(origin: regionOrigin, size: mapSize)
        regionRect = MKMapRectOffset(regionRect, -radiusInMap/2, -radiusInMap/2)
        regionRect = MKMapRectIntersection(regionRect, MKMapRectWorld)
        
        let excludePath: UIBezierPath = UIBezierPath(roundedRect: CGRect(x: regionRect.origin.x,
                                                                         y: regionRect.origin.y,
                                                                         width: regionRect.size.width,
                                                                         height: regionRect.size.height),
                                                     cornerRadius: CGFloat(regionRect.size.width) / 2)
        
        context.setFillColor(fillColor.cgColor)
        context.setStrokeColor(strokeColor.cgColor)
        context.setLineWidth(lineWidth)
        
        path.append(excludePath)
        context.addPath(path.cgPath)
        context.fillPath(using: .evenOdd)
    }
}
