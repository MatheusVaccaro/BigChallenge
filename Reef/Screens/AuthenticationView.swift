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

class AuthenticationView {
    static func auth(completion: @escaping ((Bool) -> ())) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Touch ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reason) { (succes, error) in
                                    
                                    if succes { completion(true); print("Touch ID Authentication Succeeded") }
                                    else { completion(false); print("Touch ID Authentication Failed") }
            }
        } else {
            print("touch ID unavailable")
        }
    }
}
