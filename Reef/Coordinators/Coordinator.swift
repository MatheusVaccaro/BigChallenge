//
//  Coordinator.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 23/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator: class {
    var childrenCoordinators: [Coordinator] { get set }
    func start()
    func addChild(coordinator: Coordinator)
    func releaseChild(coordinator: Coordinator)
}

protocol CoordinatorDelegate: class {
    func shouldDeinitCoordinator(_ coordinator: Coordinator)
}

extension Coordinator {
    
    var largeTitleAttributes: [NSAttributedString.Key : Any] {
        return [
            NSAttributedString.Key.font : UIFont.font(sized: 41, weight: .bold, with: .largeTitle, fontName: .barlow),
            NSAttributedString.Key.foregroundColor : ReefColors.largeTitle
        ]
    }
    
    func addChild(coordinator: Coordinator) {
        childrenCoordinators.append(coordinator)
    }
    
    func releaseChild(coordinator: Coordinator) {
        // TODO Change to removeAll when available
        childrenCoordinators.enumerated().forEach { (index, element) in
            if coordinator === element {
                childrenCoordinators.remove(at: index)
                return
            }
        }
    }
}
