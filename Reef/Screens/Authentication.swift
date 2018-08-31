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
        let reason = "Authenticate with Touch ID"
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reason) { success, error in
                                    
                                    completion(success)
            }
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication,
                                   localizedReason: reason) { success, error in
                                    completion(success)
            }
        }
    }
}
