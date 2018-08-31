//
//  DetailTableViewCell.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/8/30.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var authName: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var authPhoto: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
