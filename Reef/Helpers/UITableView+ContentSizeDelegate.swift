//
//  UITableView+ContentSizeDelegate.swift
//  Reef
//
//  Created by Matheus Vaccaro on 19/10/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

class ContentSizeObservableTableView: UITableView {
    
    override var contentSize: CGSize {
        didSet {
            contentSizeDelegate?.tableView(self, didUpdateContentSize: contentSize)
        }
    }
    
    weak var contentSizeDelegate: ContentSizeObservableTableViewDelegate?
}

protocol ContentSizeObservableTableViewDelegate: class {
    func tableView(_ tableView: ContentSizeObservableTableView, didUpdateContentSize contentSize: CGSize)
}

extension ContentSizeObservableTableViewDelegate {
    func tableView(_ tableView: ContentSizeObservableTableView, didUpdateContentSize contentSize: CGSize) { }
}
