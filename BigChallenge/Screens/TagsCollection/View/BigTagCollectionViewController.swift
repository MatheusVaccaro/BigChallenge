//
//  bigTagCollectionView.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 18/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class BigTagCollectionViewController: TagCollectionViewController {
    
    override class var tagViewControllerID: String {
        return "BigTagCollectionViewController"
    }
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagsLabel: UILabel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagsLabel.text = Strings.Tag.CollectionScreen.title
    }
    
    override func bindCollectionView() {
        viewModel.tagsObservable
        .bind(to: tagsCollectionView.rx
        .items(cellIdentifier: TagCollectionViewCell.identifier,
               cellType: TagCollectionViewCell.self)) { (row, tag, cell) in
                        
                print("updating collection with tag \(tag.title!)")
                let viewModel = self.viewModel.tagCollectionCellViewModel(for: tag)
                let index = IndexPath(row: row, section: 0)
                
                cell.configure(with: viewModel)
                self.loadSelection(for: cell, tag: tag, at: index)
                
                if row == self.viewModel.tags.count-1 {
                    self.collectionViewHeightConstraint.constant =
                        self.tagsCollectionView.collectionViewLayout.collectionViewContentSize.height
                }
                
            }.disposed(by: disposeBag)
        
        tagsCollectionView.rx.modelSelected(Tag.self).subscribe { event in // selected x item in collection
            self.viewModel.selectedTagEvent.on(event) // send to viewModel
        }.disposed(by: disposeBag)
        
        tagsCollectionView.rx.modelDeselected(Tag.self).subscribe { event in
            self.viewModel.selectedTagEvent.on(event)
        }.disposed(by: disposeBag)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
}
