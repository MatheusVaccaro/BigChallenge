//
//  TaskTableViewCell.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    // MARK: - Properties

    static let identifier = "taskCell"
    private var viewModel: TaskCellViewModel?

    // MARK: - IBOutlets
    
    @IBOutlet weak var taskTitleTextView: UITextView!
    
    // MARK: - TableViewCell Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        taskTitleTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Functions
    
    func configure(with viewModel: TaskCellViewModel) {
        self.viewModel = viewModel
        
        taskTitleTextView.text = viewModel.title
    }
}

extension TaskTableViewCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else { return }
        viewModel?.shouldChangeTask(title: text)
    }
}
