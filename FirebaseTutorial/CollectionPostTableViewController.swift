//
//  CollectionPostTableViewController.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/9/7.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class CollectionPostTableViewController: UITableViewController {
    
    var collectionReviews:[CollectionItem] = [CollectionItem]()
    var collectionPost:[CollectionPost] = [CollectionPost]()
    
    var childID:String = ""
    var uid = ""
    var status = ""
    var ref:DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.collectionPost.removeAll()
        self.collectionPost.removeAll()
        if let user = Auth.auth().currentUser{
            print("run in currerUser")
            self.uid = user.uid
            ref = Database.database().reference(withPath: "ID/\(uid)/Status")
            ref.observe(.value, with: {
                (snapshot) in
                if let status = snapshot.value{
                    let showStatus = status as! String
                    print(showStatus)
                    self.status = showStatus
                    if self.status == "Yes"{
                        self.collectionPost.removeAll()
                    }
                }else{
                    self.status = "Yes"
                }
            })
        }
        print("uid: \(uid)")
        Database.database().reference(withPath: "ID/\(uid)/Collection").queryOrderedByKey().observe(.value, with: {
            (snapshot) in
            print("run in enter uid/Collection")
            if snapshot.childrenCount > 0{
                print("run in snapshot.childrenCount > 0")
                var valueOfID: [CollectionItem] = [CollectionItem]()
                for item in snapshot.children{
                    print("run in loop for storage Post childID")
                    let data = CollectionItem(snapshot: item as! DataSnapshot)
                    valueOfID.append(data)
                }
                print("input data to coiiectionReviews")
                self.collectionReviews = valueOfID
                //-----------------download data
                var i = 0
                while i < self.collectionReviews.count{
                    print("in loop \(i)")
                    print("start to download data, POST/\(self.collectionReviews[i].childId)")
                    Database.database().reference(withPath: "POST/\(self.collectionReviews[i].childId)").queryOrderedByKey().observe(.value, with: {
                        (snapshot) in
                        print("run in self.collectionReviews[0].childId")
                        let testData = snapshot.value as! NSDictionary
                        if snapshot.childrenCount > 0{
                            print("run in snapshot")
                            var dataList: [CollectionPost] = [CollectionPost]()
                            let childId = testData["childId"]
                            let title = testData["title"]
                            let content = testData["content"]
                            let datetime = testData["dateTime"]
                            let auth = testData["auth"]
                            let photoURL = testData["photoURL"]
                            let userUID = testData["userUID"]
                            
                            let aPost = CollectionPost(childId: childId as! String, title: title as! String, content: content as! String, datetime: datetime as! String, auth: auth as! String, photoURL: photoURL as! String, userUID: userUID as! String)
                            print("aPost: \(aPost)")
                            self.collectionPost.append(aPost)
                            //                        self.collectionPost = dataList
                            print("before tableView.reloadData()")
                            self.tableView.reloadData()
                        }
                    })//end of download post
                    i = i + 1
                }
            }else{
                print("error snapshot.childrenCount < 0")
            }
            
        })
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("numberOfRowsInSection: \(collectionReviews.count)")
        //        return collectionReviews.count
        return collectionPost.count
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("collectionReviews.count: \(collectionReviews.count)")
        //        collectionPost = collectionPost.reversed()
        //        print("dataList: \(collectionPost)")
        //        print("index: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? CollectionPostTableViewCell
        cell?.showTittle.text = collectionPost[indexPath.row].title
        //        cell?.showAuth.text = dataList[indexPath.row].auth
        cell?.showDateTime.text = collectionPost[indexPath.row].datetime
        var ref:DatabaseReference!
        //download name
        ref = Database.database().reference(withPath: "ID/\(collectionPost[indexPath.row].userUID)/Profile/Name")
        ref.observe(.value, with: {
            (snapshot) in
            if let name = snapshot.value{
                let showName = name as! String
                cell?.showAuth.text = name as! String
            }else{
                cell?.showAuth.text = "user"
            }
        })
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            if let dvc = segue.destination as? DetailViewController{
                if let selectRow = tableView.indexPathForSelectedRow?.row{
                    //                    dvc.accountPhotoFromTableView = collectionPost[selectRow].auth
                    //                    dvc.authNameFromTableView = collectionPost[selectRow].auth
                    dvc.postTitleFromTableView = collectionPost[selectRow].title
                    dvc.postTimeFromTableView = collectionPost[selectRow].datetime
                    dvc.postContentFromTableView = collectionPost[selectRow].content
                    dvc.authPhotoFromTableView = collectionPost[selectRow].photoURL
                    dvc.childIDFromTableView = collectionPost[selectRow].childId
                    dvc.authUID = collectionPost[selectRow].userUID
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "刪除", handler: {
            (action,index) in
            print("delete")
            let alertController = UIAlertController(title: "取消收藏", message: "確認要取消收藏文章嗎？", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "確認", style: .default){
                (action:UIAlertAction) in
                
                Database.database().reference().child("ID/\(self.uid)/Collection/\(self.collectionPost[indexPath.row].childId)").removeValue()
                //                    self.collectionPost.remove(at: indexPath.row)
                self.collectionPost.removeAll()
                tableView.reloadData()
                Database.database().reference(withPath:"ID/\(self.uid)/Status").setValue("No")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                self.present(vc!, animated: true, completion: nil)
                //                    self.dismiss(animated: false, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        })
        deleteAction.backgroundColor = .red
        return [deleteAction]
        
    }
    
    func popAlert(titleStr:String, messageStr:String){
        let alertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
