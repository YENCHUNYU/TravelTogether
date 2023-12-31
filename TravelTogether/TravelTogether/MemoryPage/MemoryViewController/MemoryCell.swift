//
//  MemoryCell.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit

class MemoryCell: UITableViewCell {
    
    @IBOutlet weak var memoryImageView: UIImageView! {
        didSet {
            memoryImageView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var memoryNameLabel: UILabel!
    @IBOutlet weak var memoryDateLabel: UILabel!
    var taskIdentifier = ""
}
