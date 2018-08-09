//
//  NewTagViewModelProtocol.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 18/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation

protocol NewTagViewModelProtocol {
    
    var tagTitle: String? { get set }
    var colorIndex: Int64? { get set }
    var location: CLLocation? { get set }
    var placeholder: String { get }

    func didTapDeleteTagButton()
}
