//
//  AuthenticationView.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 30/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import LocalAuthentication
import UIKit

class Authentication {
    static func authenticate(completion: @escaping ((Bool) -> Void)) {
        let context = LAContext()
        var error: NSError?
        let reason = Strings.Tag.privateTagUnlockReason
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reason) { success, _ in
                                    
                                    completion(success)
            }
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication,
                                   localizedReason: reason) { success, _ in
                                    completion(success)
            }
        }
    }
}
