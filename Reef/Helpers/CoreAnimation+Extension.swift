//
//  CoreAnimation+Extension.swift
//  Reef
//
//  Created by Max Zorzetti on 21/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import QuartzCore

extension CATransaction {
    static func disableAnimationsIn(_ block: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        block()
        CATransaction.commit()
    }
}
