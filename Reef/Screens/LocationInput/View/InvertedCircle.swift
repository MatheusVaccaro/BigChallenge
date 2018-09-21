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
    
    var fillColor: UIColor = UIColor.blue.withAlphaComponent(0.2)
    var strokeColor: UIColor = UIColor.blue.withAlphaComponent(0.8)
    var lineWidth: CGFloat = 9
    var circle: MKCircle
    
    init(circle: MKCircle) {
        self.circle = circle
        super.init(overlay: circle)
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let path = UIBezierPath(rect: rect(for: MKMapRect.world))
        
        let excludePath: UIBezierPath = UIBezierPath(roundedRect: CGRect(x: circle.coordinate.latitude,
                                                                         y: circle.coordinate.longitude,
                                                                         width: circle.boundingMapRect.size.width,
                                                                         height: circle.boundingMapRect.size.height),
                                                     cornerRadius: CGFloat(circle.boundingMapRect.size.width))
        
        context.setFillColor(fillColor.cgColor)
        path.append(excludePath)
        context.addPath(path.cgPath)
        context.fillPath(using: .evenOdd)
        
        context.addPath(excludePath.cgPath)
        context.setLineWidth(lineWidth / zoomScale)
        context.setStrokeColor(strokeColor.cgColor)
        context.strokePath()
        
        //line showing circle radius
        let lineBeginPoint = CGPoint(x: excludePath.bounds.midX, y: excludePath.bounds.midY)
        let lineEndPoint = CGPoint(x: excludePath.bounds.maxX, y: excludePath.bounds.midY)
        let linePath: UIBezierPath = UIBezierPath()
        linePath.move(to: lineBeginPoint)
        linePath.addLine(to: lineEndPoint)
        
        context.addPath(linePath.cgPath)
        context.setLineWidth(6/zoomScale)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineDash(phase: 1, lengths: [20 / zoomScale, 10 / zoomScale])
        context.strokePath()
        
        // circle at the end of the line above
        let circleSize: CGFloat = 30/zoomScale
        let circleRect = CGRect(origin: CGPoint(x: lineEndPoint.x - (circleSize/2), y: lineEndPoint.y - (circleSize/2)),
                                size: CGSize(width: circleSize, height: circleSize))
        
        let circlePath: UIBezierPath =
            UIBezierPath(roundedRect: circleRect, cornerRadius: circleSize)
        
        context.addPath(circlePath.cgPath)
        context.setFillColor(UIColor.black.cgColor)
        context.fillPath()
    }
}
