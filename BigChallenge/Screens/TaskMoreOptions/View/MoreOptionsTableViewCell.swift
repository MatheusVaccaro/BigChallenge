//
//  MoreOptionsTableViewCell.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 31/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class MoreOptionsTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(with viewModel: MoreOptionsTableViewCellViewModelProtocol) {
        title.text = viewModel.title()
        subtitle.text = viewModel.subtitle()
        let image = UIImage(named: viewModel.imageName())
        button.setImage(image, for: .normal)
    }
    
}
