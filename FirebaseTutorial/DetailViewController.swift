//
//  DetailViewController.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/8/30.
//  Copyright © 2018年 TSL. All rights reserved.
//  此頁面顯示單篇貼文，包含其他使用者的回應。

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class DetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextViewDelegate {
    
    //Outlets
    @IBOutlet weak var detailTableView: UITableView!
    
    //declaration
    var accountPhotoFromTableView:String?
    var authNameFromTableView:String?
    var postTitleFromTableView:String?
    var postTimeFromTableView:String?
    var postContentFromTableView:String?
    var authPhotoFromTableView:String!
    var childIDFromTableView:String?
    var authUID:String!
    var currerUID:String?
    var responseReviews:[ResponseItem] = [ResponseItem]()
    var replyPhoto:[UIImage] = [UIImage]()
    var ref:DatabaseReference!

    //先取得當前使用者uid
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTableView.delegate = self
        detailTableView.dataSource = self
        
        if let user = Auth.auth().currentUser{
            currerUID = user.uid
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //下載所有回應
        if let childID = childIDFromTableView {
            print("run in download response data")
            Database.database().reference(withPath: "POST/\(childID)/reply").queryOrderedByKey().observe(.value, with: {
                (snapshot) in
                if snapshot.childrenCount > 0{
                    var dataListResponse: [ResponseItem] = [ResponseItem]()
                    
                    for item in snapshot.children{
                        let data = ResponseItem(snapshot: item as! DataSnapshot)
                        dataListResponse.append(data)
                    }
                    self.responseReviews = dataListResponse
                    self.detailTableView.reloadData()
                    print("download response end")
                }
            })//End of download reply
        }
    }//End of viewDidAppear

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //設定 TableView 的 Section 數量
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    //設定每個 Section 的 Row 數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            if responseReviews.count < 1{
                return 0
            }else{
                return responseReviews.count
            }
        }
    }
    //設定 Section 的標題
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "回應"
        }else{
            return ""
        }
    }
    
    //設定 Row 的內容並顯示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if let cellPost = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DetailTableViewCell{
                //顯示貼文標題、內容、時間
                cellPost.postTitle.text = postTitleFromTableView
                cellPost.postTime.text = postTimeFromTableView
                cellPost.postContent.text = postContentFromTableView
                if let uid = authUID{
                    //下載貼文作者名稱（因作者有可能修改名稱，所以名稱改成每次從資料庫下載）
                    ref = Database.database().reference(withPath: "ID/\(uid)/Profile/Name")
                    ref.observe(.value, with: {
                        (snapshot) in
                        if let name = snapshot.value{
                            let showName = name as! String
                            cellPost.authName.text = showName
                        }else{
                            cellPost.authName.text = "User"
                        }
                    })//End of download name
                    
                    //下載貼文作者照片（因作者有可能修改照片，所以照片改成每次從資料庫下載）
                    ref = Database.database().reference(withPath: "ID/\(uid)/Profile/Photo")
                    ref.observe(.value, with: {
                        (snapshot) in
                        if let photo = snapshot.value{
                            let showPhoto = photo as! String
                            //download photo
                            let maxSize:Int64 = 25 * 1024 * 1024
                            //authPhotoFromTableView!
                            Storage.storage().reference(forURL: showPhoto).getData(maxSize: maxSize, completion: {
                                (data,error) in
                                if error != nil{
                                    print("Photo error")
                                    return
                                }
                                guard let imageData = UIImage(data: data!) else { return }
                                DispatchQueue.main.async {
                                    cellPost.authPhoto.image = imageData
                                }
                            })//End of download photo data
                        }else{
                           print("photo error")
                        }
                    })//End of download photo url
                }//End of uid = authUID
                cellPost.postContent.delegate = self
                return cellPost
            }else{
                let cellPost = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cellPost.textLabel?.text = "Error"
                return cellPost
            }
        }else{
            if let cellResponse = tableView.dequeueReusableCell(withIdentifier: "responseCell", for: indexPath) as? ResponseTableViewCell{
                //顯示回應的內容、時間
                cellResponse.replyTime.text = self.responseReviews[indexPath.row].datetime
                cellResponse.replyContent.text = self.responseReviews[indexPath.row].content
                //下載回應者名稱（因作者有可能修改名稱，所以名稱改成每次從資料庫下載）
                ref = Database.database().reference(withPath: "ID/\(responseReviews[indexPath.row].userUID)/Profile/Name")
                ref.observe(.value, with: {
                    (snapshot) in
                    if let name = snapshot.value{
                        let showName = name as! String
                        print(showName)
                        cellResponse.replyName.text = showName
                    }else{
                        cellResponse.replyName.text = "User"
                    }
                })//End of download name
                
                //下載回應者照片（因作者有可能修改照片，所以照片改成每次從資料庫下載）
                ref = Database.database().reference(withPath: "ID/\(responseReviews[indexPath.row].userUID)/Profile/Photo")
                ref.observe(.value, with: {
                    (snapshot) in
                    if let photo = snapshot.value{
                        let showPhoto = photo as! String
                        //download photo
                        let maxSize:Int64 = 25 * 1024 * 1024
                        //authPhotoFromTableView!
                        Storage.storage().reference(forURL: showPhoto).getData(maxSize: maxSize, completion: {
                            (data,error) in
                            if error != nil{
                                print("Photo error")
                                return
                            }
                            guard let imageData = UIImage(data: data!) else { return }
                            DispatchQueue.main.async {
                                cellResponse.replyPhoto.image = imageData
                            }
                        })//End of download photo data
                    }else{
                        print("photo error")
                    }
                })//End of download photo url
                cellResponse.replyContent.delegate = self
                return cellResponse
            }else{
                let cellResponse = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cellResponse.textLabel?.text = "Error"
                return cellResponse
            }
        }
        
    }
    //貼文右上方的按鈕
    @IBAction func actionMenu(_ sender: UIBarButtonItem) {
        //這邊的邏輯是如果貼文的作者是自己，那只顯示編輯跟回應，不顯示收藏，
        //如果作者不是自己，那只顯示收藏跟回應，不顯示編輯。
        let actionController = UIAlertController(title: "更多動作", message: "請選擇要執行的動作", preferredStyle: .actionSheet)
        let replyAction = UIAlertAction(title: "回應文章", style: .default){
            (action:UIAlertAction) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "replyPost") as! ResponseViewController
            vc.childIDFromDetailTableView = self.childIDFromTableView
            self.present(vc, animated: true, completion: nil)
        }//End of replyAction
        let updateAction = UIAlertAction(title: "編輯文章", style: .default){
            (action:UIAlertAction) in
            print("delete post in show post page")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "updatePost") as! UpdateViewController
            vc.titleFromDetailTableView = self.postTitleFromTableView
            vc.contentFromDetailTableView = self.postContentFromTableView
            vc.childIDFromDetailTableView = self.childIDFromTableView
            self.present(vc, animated: true, completion: nil)
        }//End of updateAction
        
        //收藏文章目前有 bug ，若已經收藏的文章被原作者移除，則會崩潰，預計調整刪除功能應對。
        let collectionAction = UIAlertAction(title: "收藏文章", style: .default){
            (action:UIAlertAction) in
            if let uid = self.currerUID{
                let reference = Database.database().reference().child("ID/\(uid)/Collection")
                var collection:[String : AnyObject] = [String : AnyObject]()
                collection["childId"] = self.childIDFromTableView as AnyObject
                let collectionReference = reference.child(self.childIDFromTableView!)
                collectionReference.updateChildValues(collection){
                    (error,ref) in
                    if error != nil{
                        print(error?.localizedDescription)
                        return
                    }
                    print(ref.description())
                }
                //增加寫入一個 Status 做顯示收藏文章時的判斷，但顯示收藏文章的頁面還是會有小問題。
                Database.database().reference(withPath:"ID/\(uid)/Status").setValue("Yes")
            }
        }//End of collectionAction
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        //針對不同的使用者做不同的顯示（已經在此function最上方說明）。
        if currerUID == authUID{
            actionController.addAction(replyAction)
            actionController.addAction(updateAction)
            actionController.addAction(cancelAction)
        }else{
            actionController.addAction(replyAction)
            actionController.addAction(collectionAction)
            actionController.addAction(cancelAction)
        }
        self.present(actionController, animated: true, completion: nil)
    }
    
    //設定 TableView 每一個 Row 的滑動動作
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //這邊的邏輯是如果刪除的回應是自己發表的，那可成功刪除，反之則顯示失敗。
        //declaration
        let replyUID = self.responseReviews[indexPath.row].userUID
        var isRemove = false
        
        //判斷回應者與當下登入使用者是否相符
        if currerUID == replyUID{
            isRemove = true
        }
        //設定刪除按鈕
        let deleteAction = UITableViewRowAction(style: .normal, title: "刪除", handler: {
            (action,index) in
            if isRemove == true{
                let alertController = UIAlertController(title: "刪除確認", message: "確認要刪除回覆嗎？", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "確認", style: .default){
                    (action:UIAlertAction) in
                    Database.database().reference().child("POST/\(self.childIDFromTableView!)/reply/\(self.responseReviews[indexPath.row].childId)").removeValue()
                    self.responseReviews.remove(at: indexPath.row)
                    self.detailTableView.reloadData()
                }
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        })//End of deleteAction
        deleteAction.backgroundColor = .red
        
        //設定編輯回應按鈕
        //這邊因為考慮編輯的模式，故暫時沒有完成，所以下方不回傳。
        let editAction = UITableViewRowAction(style: .normal, title: "編輯", handler: {
            (action,index) in
            print("edit response")
        })//End of editAction
        
        //針對不同的使用者做不同的顯示（已經在此function最上方說明）。
        if isRemove == true{
            return [deleteAction]
        }else{
            return nil
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
