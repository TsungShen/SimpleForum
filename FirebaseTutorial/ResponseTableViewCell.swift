//
//  ResponseTableViewCell.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/8/31.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import UIKit

class ResponseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var replyPhoto: UIImageView!
    @IBOutlet weak var replyName: UILabel!
    @IBOutlet weak var replyTime: UILabel!
    @IBOutlet weak var replyContent: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
