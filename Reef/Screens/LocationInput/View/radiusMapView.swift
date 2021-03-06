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
    
    var isEmpty: Bool = true
    var placeName: String? {
        didSet {
            _accessibilityValue = nil
        }
    }
    private var radius: Double = 100 {
        didSet {
            _accessibilityValue = nil
        }
    }
    public var arriving: Bool = true {
        didSet {
            changeCircle(to: radius)
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
            changeCircle(to: radius + Double(totalDistance * CGFloat(multiplier))) // raise multiplier based on distance
        }
    }
    
    override func addOverlay(_ overlay: MKOverlay) {
        if let circle = overlay as? MKCircle {
            let spanToFit = viewModel.spanToFit(circle: circle)
            let span = MKCoordinateSpan(latitudeDelta: spanToFit, longitudeDelta: spanToFit)
            let region = MKCoordinateRegion(center: circle.coordinate,
                                            span: span)
            
            setRegion(region, animated: true)
            isEmpty = false
            
            if annotations.isEmpty {
                let annotation = MKPointAnnotation()
                annotation.coordinate = circle.coordinate
                addAnnotation(annotation)
            }
        }
        super.addOverlay(overlay)
    }
    
    fileprivate func changeCircle(to newRadius: Double) {
        guard let circleOverlay = overlays.first as? MKCircle else { return }
        self.radius = newRadius
        
        guard viewModel.shouldReplaceOverlay(with: newRadius) else { return }
        
        removeOverlay(circleOverlay)
        let newOverlay = MKCircle(center: circleOverlay.coordinate,
                                  radius: newRadius)
        outputDelegate?.radiusMapView(self,
                                      didFind: CLCircularRegion(center: newOverlay.coordinate,
                                                                radius: newRadius,
                                                                identifier: String(describing: newOverlay.coordinate)))
        addOverlay(newOverlay)
    }
    
    // MARK: - Accessibility
    private var _accessibilityValue: String?
    override var accessibilityValue: String? {
        get {
            guard _accessibilityValue == nil else { return _accessibilityValue }
            
            if isEmpty {
                _accessibilityValue = Strings.LocationInputView.VoiceOver.mapValueEmpty
            } else {
                let localizedString = Strings.LocationInputView.VoiceOver.mapValue
                let defaultPlaceName = Strings.LocationInputView.defaultPlaceName
                
                _accessibilityValue = String.localizedStringWithFormat(localizedString,
                                                                       Int(radius).description,
                                                                       placeName ?? defaultPlaceName)
            }
            
            return _accessibilityValue
        }
        set { _accessibilityValue = accessibilityValue }
    }
    
    override func accessibilityDecrement() {
        changeCircle(to: radius - 100)
    }
    
    override func accessibilityIncrement() {
        changeCircle(to: radius + 100)
    }
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return UIAccessibilityTraits.adjustable
        }
        set { }
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
