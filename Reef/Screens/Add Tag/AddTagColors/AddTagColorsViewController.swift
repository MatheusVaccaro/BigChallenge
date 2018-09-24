//
//  AddTagColorsViewController.swift
//  Reef
//
//  Created by Gabriel Paul on 24/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class AddTagColorsViewController: UIViewController {

    @IBOutlet weak var tagColorsCollectionView: UICollectionView!
    // MARK: - Properties
    var viewModel: AddTagColorsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagColorsCollectionView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddTagColorsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        viewModel?.colorIndex = row
    }
}

extension AddTagColorsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfColors()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier,
                                                            for: indexPath) as? ColorCollectionViewCell else {
                                                                return UICollectionViewCell()
        }
        
        cell.configure(with: indexPath.row)
        return cell
    }
}
