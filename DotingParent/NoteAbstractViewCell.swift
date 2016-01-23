//
//  NoteAbstractCell.swift
//  DotingParent
//
//  Created by 酒井紀明 on 2016/01/23.
//  Copyright © 2016年 noriaki.sakai. All rights reserved.
//

import UIKit

class NoteAbstractViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var movieImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
