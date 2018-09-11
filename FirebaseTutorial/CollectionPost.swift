//
//  CollectionPost.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/9/7.
//  Copyright © 2018年 TSL. All rights reserved.
//  存放 CollectionPost 的 Stuuct

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
}
