//
//  VerticallyCenteredTextView.swift
//  Reef
//
//  Created by Matheus Vaccaro on 23/10/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

class VerticallyCenteredTextView: UITextView {
    
    var contentSizeDelegate: UITextViewContentSizeDelegate?
    
    override var contentSize: CGSize {
        didSet {
            contentSizeDelegate?.textView(self, didChangeContentSize: contentSize)
            
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
}

protocol UITextViewContentSizeDelegate {
    func textView(_ textView: UITextView, didChangeContentSize contentSize: CGSize)
}

extension UITextViewContentSizeDelegate {
    func textView(_ textView: UITextView, didChangeContentSize contentSize: CGSize) { }
}
