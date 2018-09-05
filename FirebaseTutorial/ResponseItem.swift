//
//  ResponseItem.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/9/1.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import Foundation
import Firebase

struct ResponseItem {
    var childId: String
    var content: String
    var datetime: String
    var reply: String
    var photoURL: String
    var userUID: String
    
    init(snapshot: DataSnapshot) {
        //        print("snapshot: \(snapshot.value)")
        
        let snapshotValue: [String: AnyObject] = snapshot.value as! [String : AnyObject]
        self.childId = snapshotValue["childId"] as! String
        self.content = snapshotValue["content"] as! String
        self.datetime = snapshotValue["dateTime"] as! String
        self.reply = snapshotValue["reply"] as! String
        self.photoURL = snapshotValue["photoURL"] as! String
        self.userUID = snapshotValue["userUID"] as! String
    }
}
