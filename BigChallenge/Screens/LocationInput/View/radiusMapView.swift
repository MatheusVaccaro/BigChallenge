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
    
    var viewModel: RadiusMapViewModel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        viewModel = RadiusMapViewModel()
        delegate = self
        isZoomEnabled = false
        isScrollEnabled = false
    }
    
    public var arriving: Bool = true {
        didSet {
            changeCircle(adding: 0)
        }
    }
    
    weak var outputDelegate: RadiusMapViewDelegate?
    
    private(set) var circularRegion: CLCircularRegion? {
        didSet {
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
            
            let multiplier = 100 * region.span.latitudeDelta
            changeCircle(adding: Double(totalDistance * CGFloat(multiplier))) // raise multiplier based on distance
        }
    }
    
    override func add(_ overlay: MKOverlay) {
        if let circle = overlay as? MKCircle {
            circularRegion = CLCircularRegion(center: circle.coordinate,
                                              radius: circle.radius,
                                              identifier: "outPutRegion")
            
            let spanToFit = viewModel.spanToFit(circle: circle)
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
        super.add(overlay)
    }
    
    fileprivate func changeCircle(adding radius: Double) {
        guard let circleOverlay = overlays.first as? MKCircle else { return }
        let newRadius = circleOverlay.radius + radius
        
        guard viewModel.shouldReplaceOverlay(with: newRadius) else { return }
        
        remove(circleOverlay)
        let newOverlay = MKCircle(center: circleOverlay.coordinate,
                                  radius: newRadius)
        add(newOverlay)
    }
}

extension RadiusMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            if arriving {
                let circleRenderer = MKCircleRenderer(circle: overlay)
                
                circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.2)
                circleRenderer.strokeColor = UIColor.blue.withAlphaComponent(0.8)
                circleRenderer.lineWidth = 3
                
                return circleRenderer
            } else {
                let invertedRenderer = MKInvertedCircleOverlayRenderer(circle: overlay)
                
                invertedRenderer.fillColor = UIColor.blue.withAlphaComponent(0.2)
                invertedRenderer.strokeColor = UIColor.blue
                
                return invertedRenderer
            }
        } else {
            return MKOverlayRenderer()
        }
    }
}
