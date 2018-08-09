//
//  CreateTagViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 09/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class CreateTagViewController: UIViewController {

    @IBOutlet weak var tagTitleTextView: UITextView!
    var viewModel: NewTagViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    fileprivate func setup(_ textView: UITextView) {
        textView.adjustsFontForContentSizeCategory = true
        textView.font =
            UIFont.font(sized: 38.0, weight: .bold, with: .title1, fontName: .barlow)
    }

}

extension CreateTagViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.tagTitle = textView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return text.count < 100 ? true : false //TODO test possible sizes
    }
}
