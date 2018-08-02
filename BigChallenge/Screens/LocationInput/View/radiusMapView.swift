//
//  radiusMapView.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import MapKit

protocol RadiusMapViewDelegate: class {
    func radiusMapView(_ radiusMapView: RadiusMapView, didFind region: CLCircularRegion)
}

class RadiusMapView: MKMapView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        delegate = self
        isZoomEnabled = false
        isScrollEnabled = false
    }
    
    weak var outputDelegate: RadiusMapViewDelegate?
    
    private(set) var circularRegion: CLCircularRegion? {
        didSet {
            guard circularRegion != nil else { return }
            outputDelegate?.radiusMapView(self, didFind: circularRegion!)
        }
    }
    
    fileprivate var startLocation: CGPoint?
    fileprivate var totalDistance: CGFloat = 0
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            totalDistance = 0
            startLocation = touch.location(in: inputView)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let startLocation = startLocation, let touch = touches.first {
            
            let currentLocation = touch.location(in: inputView)
            
            let distanceX = currentLocation.x - startLocation.x
            
            self.totalDistance = distanceX
            self.startLocation = currentLocation
            
            changeCircle(with: Double(totalDistance * 5)) // raise multiplier based on distance
        }
    }
    
    override func add(_ overlay: MKOverlay) {
        super.add(overlay)
        if let circle = overlay as? MKCircle {
            circularRegion = CLCircularRegion(center: circle.coordinate,
                                              radius: circle.radius,
                                              identifier: "outPutRegion")
            
            let spanToFit = 0.0001 * circle.radius
            let span = MKCoordinateSpanMake(spanToFit, spanToFit)
            let region = MKCoordinateRegion(center: circle.coordinate,
                                            span: span)
            
            setRegion(region, animated: true)
            
            if annotations.isEmpty {
                let point = MKPointAnnotation()
                point.coordinate = circle.coordinate
                addAnnotation(point)
            }
        }
    }
    
    fileprivate func changeCircle(with radius: Double) {
        guard let circleOverlay = overlays.first as? MKCircle else { return }
        let newRadius = circleOverlay.radius + radius
        
        guard newRadius > 100 && newRadius < 100000 else { return }
        
        remove(circleOverlay)
        let newOverlay = MKCircle(center: circleOverlay.coordinate,
                                  radius: newRadius)
        add(newOverlay)
    }
}

extension RadiusMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            
            circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.2)
            circleRenderer.strokeColor = UIColor.blue.withAlphaComponent(0.8)
            circleRenderer.lineWidth = 3
            
            return circleRenderer
        } else {
            return MKOverlayRenderer()
        }
    }
}
