//
//  TaskTableViewCell.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

protocol TaskCellDelegate: class {
    func shouldUpdateSize(of cell: TaskTableViewCell)
}

class TaskTableViewCell: UITableViewCell {
    
    // MARK: - Properties

    static let identifier = "taskCell"
    weak var delegate: TaskCellDelegate?
    private var viewModel: TaskCellViewModel?
    private var previousRect = CGRect.zero
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var taskTitleTextView: UITextView!
    @IBOutlet weak var checkButton: UIButton!
    
    // MARK: - TableViewCell Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        taskTitleTextView.delegate = self
        checkButton.isSelected = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Functions
    
    func configure(with viewModel: TaskCellViewModel) {
        self.viewModel = viewModel
        
        taskTitleTextView.text = viewModel.title
        taskTitleTextView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    }
    
    // MARK: - IBActions
    
    @IBAction func didPressCheckButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel?.shouldCompleteTask(checkButton.isSelected)
    }
}

extension TaskTableViewCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else { return }
        viewModel?.shouldChangeTask(title: text)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let lastCharPos = textView.endOfDocument

        let currentRect = textView.caretRect(for: lastCharPos)
        if currentRect.origin.y < previousRect.origin.y {
            delegate?.shouldUpdateSize(of: self)
        }
        previousRect = currentRect
    }
}
