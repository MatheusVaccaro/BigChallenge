//
//  RadiusMapViewModel.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 05/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import MapKit

class RadiusMapViewModel {
    func spanToFit(circle: MKCircle) -> Double {
        return circle.radius*2 / 40000
    }
    
    func shouldReplaceOverlay(with radius: Double) -> Bool {
        return radius >= 100 && radius <= 1000000
    }
}
