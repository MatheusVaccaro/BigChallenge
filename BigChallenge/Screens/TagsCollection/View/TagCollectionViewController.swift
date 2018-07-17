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
            let viewModel = self.viewModel.tagCollectionCellViewModel(for: tag)
            cell.configure(with: viewModel)
        }.disposed(by: disposeBag)
        
        // selected x item in collection
        tagsCollectionView.rx.modelSelected(Tag.self).subscribe { event in
            // send to viewModel
            self.viewModel.selectedTagEvent.on(event)
        }.disposed(by: disposeBag)
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
