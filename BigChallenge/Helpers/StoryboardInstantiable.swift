//
//  StoryboardInstantiable.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

protocol StoryboardInstantiable {
    
    static var storyboardName: String { get }
    static var storyboardBundle: Bundle? { get }
    static var storyboardIdentifier: String { get }
    
}

extension StoryboardInstantiable {
    
    static var storyboardBundle: Bundle? { return nil }
    
    static func instantiate() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
        
        guard let viewController =
            storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as? Self else {
            
                fatalError("Could not instantiate \(self)")
        }
        return viewController
    }
    
}
