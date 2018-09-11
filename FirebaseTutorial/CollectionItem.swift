//
//  CollectionItem.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/9/7.
//  Copyright © 2018年 TSL. All rights reserved.
//  用來解析 CollectionPostTableViewController 下載的文章ChildID

import Foundation
import Firebase

struct CollectionItem {
    var childId: String
    
    init(snapshot: DataSnapshot) {
        
        let snapshotValue: [String: AnyObject] = snapshot.value as! [String : AnyObject]
        self.childId = snapshotValue["childId"] as! String

    }
}

