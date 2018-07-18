//
//  TagsCollectionViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TagCollectionViewController: UIViewController {

    public var tagsObservable: BehaviorSubject<[Tag]> {
        return viewModel!.tagsObservable
    }
    
    var viewModel: TagCollectionViewModel!
    var clickedTagEvent: BehaviorSubject<Tag>?
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindCollectionView()
        tagsCollectionView.allowsMultipleSelection = true
        if let layout = tagsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 150, height: 40)
        }
    }
    
    func bindCollectionView() {
        viewModel.tagsObservable
        .bind(to: tagsCollectionView.rx.items(cellIdentifier: TagCollectionViewCell.identifier,
                                              cellType: TagCollectionViewCell.self)) { (_, tag, cell) in
            
            print("updating collection with tag \(tag.title!)")
            let tagViewModel = self.viewModel.tagCollectionCellViewModel(for: tag)
            cell.configure(with: tagViewModel)
                                                
            cell.touchedTagEvent?.subscribe { event in
                guard let touch = event.element else {return}
                if self.shouldPresentBigCollection(on: touch) { self.presentBigCollection() }
            }
        }.disposed(by: disposeBag)
        
        tagsCollectionView.rx.modelSelected(Tag.self).subscribe { event in // selected x item in collection
            self.viewModel.selectedTagEvent.on(event) // send to viewModel
        }.disposed(by: disposeBag)
        
        tagsCollectionView.rx.modelDeselected(Tag.self).subscribe { event in
            self.viewModel.selectedTagEvent.on(event)
        }.disposed(by: disposeBag)
    }
    
    func shouldPresentBigCollection(on touch: UITouch) -> Bool {
        if self.traitCollection.forceTouchCapability == .available {
            let force = touch.force/touch.maximumPossibleForce
            if force >= 0.5 { return true }
        } else if false {
            //HANDLE LONG PRESS
        }
        return false
    }
    
    func presentBigCollection() {
        let bigTagVC = BigTagCollectionViewController.instantiate()
        bigTagVC.viewModel = self.viewModel
        bigTagVC.modalPresentationStyle = .overCurrentContext
        bigTagVC.modalTransitionStyle = .crossDissolve
        
        present(bigTagVC, animated: true)
    }
}

extension TagCollectionViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "TagCollectionViewController"
    }
    
    static var storyboardIdentifier: String {
        return "TagCollection"
    }
}
