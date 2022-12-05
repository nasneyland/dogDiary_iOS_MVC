//
//  EtcTableViewCell.swift
//  dogDiary
//
//  Created by najin on 2021/02/16.
//

import UIKit

class EtcTableViewCell: UITableViewCell {
    
    @IBOutlet weak var etcStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
