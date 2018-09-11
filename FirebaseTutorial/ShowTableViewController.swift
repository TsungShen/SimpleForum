//
//  ShowTableViewController.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/8/25.
//  Copyright © 2018年 TSL. All rights reserved.
//  此頁面為顯示所有貼文的動態牆

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ShowTableViewController: UITableViewController {
    
    //declaration
    var postReviews: [PostItem] = [PostItem]()
    var ref:DatabaseReference!
    var childID: String = ""
    
    //下載所有貼文
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Database.database().reference(withPath: "POST").queryOrderedByKey().observe(.value, with: {
            (snapshot) in
            if snapshot.childrenCount > 0{
                var dataList: [PostItem] = [PostItem]()
                
                for item in snapshot.children{
                    let data = PostItem(snapshot: item as! DataSnapshot)
                    dataList.append(data)
                }
                //將陣列反轉儲存，讓新貼文可以在頂端顯示
                self.postReviews = dataList.reversed()
                self.tableView.reloadData()
            }
        })//End of download post
    }//End of viewWillAppear
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //新增一則新貼文的按鈕
    @IBAction func addNewPost(_ sender: UIBarButtonItem) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "addNewPost")
        self.present(vc!, animated: true, completion: nil)
    }
    
    //設定 TableView 的 Section 數量
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    //設定每個 Section 的 Row 數量
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.postReviews.count
    }
    
    //設定 Row 的內容並顯示
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? ShowTableViewCell
        //顯示標題、內容
        cell?.showTitle.text = postReviews[indexPath.row].title
        cell?.showDateTime.text = postReviews[indexPath.row].datetime
        
        //下載貼文作者名稱（因作者有可能修改名稱，所以名稱改成每次從資料庫下載）
        ref = Database.database().reference(withPath: "ID/\(postReviews[indexPath.row].userUID)/Profile/Name")
        ref.observe(.value, with: {
            (snapshot) in
            if let name = snapshot.value{
                let showName = name as! String
                cell?.showAuth.text = name as! String
            }else{
                cell?.showAuth.text = "user"
            }
        })//End of download name
        return cell!
    }
    
    //設定 TableView 每一個 Row 的滑動動作
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //這邊的邏輯是如果刪除的貼文是自己發表的，那可成功刪除，反之則顯示失敗。
        //因為新增了文章收藏功能，為了避免原作者刪文後造成其他有收藏文章的用戶崩潰，故未來將調整刪除功能。
        
        //declaration
        let authUID = postReviews[indexPath.row].userUID
        let currentUID = Auth.auth().currentUser?.uid
        var isRemove = false
        
        //判斷作者與當下登入使用者是否相符
        if authUID == currentUID{
            isRemove = true
        }
        let deleteAction = UITableViewRowAction(style: .normal, title: "刪除", handler: {
            (action,index) in
            if isRemove == true{
                print("delete")
                let alertController = UIAlertController(title: "刪除確認", message: "確認要刪除文章嗎？", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "確認", style: .default){
                    (action:UIAlertAction) in
                    Database.database().reference().child("POST/\(self.postReviews[indexPath.row].childId)").removeValue()
                    self.postReviews.remove(at: indexPath.row)
                    tableView.reloadData()
                }//End of defaultAction
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }else{
                print("Not auth don't remove")
                self.popAlert(titleStr: "刪除失敗", messageStr: "非本篇文章作者，不可刪除")
            }
            
        })//End of deleteAction
        deleteAction.backgroundColor = .red
        return [deleteAction]
    }
    
    //將內容傳入貼文單篇顯示頁面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            if let dvc = segue.destination as? DetailViewController{
                if let selectRow = tableView.indexPathForSelectedRow?.row{
                    dvc.accountPhotoFromTableView = postReviews[selectRow].auth
                    dvc.authNameFromTableView = postReviews[selectRow].auth
                    dvc.postTitleFromTableView = postReviews[selectRow].title
                    dvc.postTimeFromTableView = postReviews[selectRow].datetime
                    dvc.postContentFromTableView = postReviews[selectRow].content
                    dvc.authPhotoFromTableView = postReviews[selectRow].photoURL
                    dvc.childIDFromTableView = postReviews[selectRow].childId
                    dvc.authUID = postReviews[selectRow].userUID
                }
            }
        }
    }
    //警告控制器
    func popAlert(titleStr:String, messageStr:String){
        let alertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
