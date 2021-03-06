//
//  Colors.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 22/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    
    public static let tagColors = [
            UIColor.Tags.peachGradient,
            UIColor.Tags.redGradient,
            UIColor.Tags.purpleGradient,
            UIColor.Tags.greenGradient,
            UIColor.Tags.yellowGradient
    ]
    
    public struct Tags {
        
        public static let purpleGradient: [CGColor] = [
            UIColor(red: 207/255, green: 0, blue: 238/255, alpha: 1).cgColor,
            UIColor(red: 115/255, green: 0, blue: 217/255, alpha: 1).cgColor
        ]
        
        public static let redGradient: [CGColor] = [
            UIColor(red: 245/255, green: 81/255, blue: 95/255, alpha: 1).cgColor,
            UIColor(red: 159/255, green: 4/255, blue: 27/255, alpha: 1).cgColor
        ]
        
        public static let peachGradient: [CGColor] = [
            UIColor(red: 250/255, green: 97/255, blue: 190/255, alpha: 1).cgColor,
            UIColor(red: 247/255, green: 107/255, blue: 28/255, alpha: 1).cgColor
        ]
        
        public static let greenGradient: [CGColor] = [
            UIColor(red: 0, green: 238/255, blue: 151/255, alpha: 1).cgColor,
            UIColor(red: 11/255, green: 179/255, blue: 83/255, alpha: 1).cgColor
        ]
        
        public static let yellowGradient: [CGColor] = [
            UIColor(red: 255/255, green: 189/255, blue: 66/255, alpha: 1).cgColor,
            UIColor(red: 255/255, green: 224/255, blue: 40/255, alpha: 1).cgColor
        ]    
    }
}
