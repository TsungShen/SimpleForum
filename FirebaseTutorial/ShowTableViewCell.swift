//
//  ShowTableViewCell.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/8/25.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import UIKit

class ShowTableViewCell: UITableViewCell {

    @IBOutlet weak var showTitle: UILabel!
    @IBOutlet weak var showAuth: UILabel!
    @IBOutlet weak var showDateTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
