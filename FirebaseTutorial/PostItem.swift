//
//  PostItem.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/8/25.
//  Copyright © 2018年 TSL. All rights reserved.
//  用來解析 ShowTableViewController 下載的貼文內容

import Foundation
import Firebase

struct PostItem {
    var childId: String
    var title: String
    var content: String
    var datetime: String
    var auth: String
    var photoURL: String
    var userUID: String
    
    init(snapshot: DataSnapshot) {
        let snapshotValue: [String: AnyObject] = snapshot.value as! [String : AnyObject]
        self.childId = snapshotValue["childId"] as! String
        self.title = snapshotValue["title"] as! String
        self.content = snapshotValue["content"] as! String
        self.datetime = snapshotValue["dateTime"] as! String
        self.auth = snapshotValue["auth"] as! String
        self.photoURL = snapshotValue["photoURL"] as! String
        self.userUID = snapshotValue["userUID"] as! String
        }
}
