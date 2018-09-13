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
        isAccessibilityElement = true
    }
    
    public var arriving: Bool = true {
        didSet {
            changeCircle(adding: 0)
        }
    }
    
    weak var outputDelegate: RadiusMapViewDelegate?
        
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
            
            let multiplier = 150 * region.span.latitudeDelta
            changeCircle(adding: Double(totalDistance * CGFloat(multiplier))) // raise multiplier based on distance
        }
    }
    
    override func add(_ overlay: MKOverlay) {
        if let circle = overlay as? MKCircle {
            let spanToFit = viewModel.spanToFit(circle: circle)
            let span = MKCoordinateSpanMake(spanToFit, spanToFit)
            let region = MKCoordinateRegion(center: circle.coordinate,
                                            span: span)
            
            setRegion(region, animated: true)
            
            if annotations.isEmpty {
                let annotation = MKPointAnnotation()
                annotation.coordinate = circle.coordinate
                addAnnotation(annotation)
            }
        }
        super.add(overlay)
    }
    
    fileprivate func changeCircle(adding radius: Double) {
        guard let circleOverlay = overlays.first as? MKCircle else { return }
        let newRadius = circleOverlay.radius + radius
        self.radius = newRadius
        
        guard viewModel.shouldReplaceOverlay(with: newRadius) else { return }
        
        remove(circleOverlay)
        let newOverlay = MKCircle(center: circleOverlay.coordinate,
                                  radius: newRadius)
        outputDelegate?.radiusMapView(self,
                                      didFind: CLCircularRegion(center: newOverlay.coordinate,
                                                                radius: newRadius,
                                                                identifier: String(describing: newOverlay.coordinate)))
        add(newOverlay)
    }
    
    // MARK: - Accessibility
    var placeName: String? {
        didSet { _accessibilityValue = nil }
    }
    private var radius: Double = 100 {
        didSet { _accessibilityValue = nil }
    }
    
    private var _accessibilityValue: String?
    override var accessibilityValue: String? {
        get {
            guard _accessibilityValue == nil else { return _accessibilityValue }
            
            let localizedString = Strings.LocationInputView.VoiceOver.mapValue
            let defaultPlaceName = Strings.LocationInputView.defaultPlaceName
            
            _accessibilityValue = String.localizedStringWithFormat(localizedString,
                                                                   radius.description,
                                                                   placeName ?? defaultPlaceName)
            return _accessibilityValue
        }
        set { _accessibilityValue = accessibilityValue }
    }
}

extension RadiusMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            if arriving {
                return MKRadiusCircleRenderer(circle: overlay)
            } else {
                return MKInvertedCircleOverlayRenderer(circle: overlay)
            }
        } else {
            return MKOverlayRenderer()
        }
    }
}
