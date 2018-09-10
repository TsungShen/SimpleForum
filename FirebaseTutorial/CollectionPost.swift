//
//  CollectionPost.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/9/7.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import Foundation
import Firebase

struct CollectionPost {
    var childId: String
    var title: String
    var content: String
    var datetime: String
    var auth: String
    var photoURL: String
    var userUID: String
    //    var reply: String
    
//    init(snapshot: DataSnapshot) {
//        //        print("snapshot: \(snapshot.value)")
//        
//        let snapshotValue: [String: AnyObject] = snapshot.value as! [String : AnyObject]
//        self.childId = snapshotValue["childId"] as! String
//        self.title = snapshotValue["title"] as! String
//        self.content = snapshotValue["content"] as! String
//        self.datetime = snapshotValue["dateTime"] as! String
//        self.auth = snapshotValue["auth"] as! String
//        self.photoURL = snapshotValue["photoURL"] as! String
//        self.userUID = snapshotValue["userUID"] as! String
//        //        self.reply = snapshotValue["reply"] as! String
//    }
    
}
