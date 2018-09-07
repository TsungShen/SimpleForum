//
//  CollectionPostTableViewCell.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/9/7.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import UIKit

class CollectionPostTableViewCell: UITableViewCell {
    @IBOutlet weak var showTittle: UILabel!
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
