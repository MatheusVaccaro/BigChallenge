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
        
        // get list of selected elements from viewModel
        viewModel.selectedTagsObservable.subscribe { event in
            print("selected tags are: \( event.element!.map {$0.title} )")
        }
        
        //TODO
        tagsCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
}

extension TagCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 50)
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
