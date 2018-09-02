//
//  DetailViewController.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/8/30.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class DetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextViewDelegate {
    @IBOutlet weak var detailTableView: UITableView!
    
    var accountPhotoFromTableView:String?
    var authNameFromTableView:String?
    var postTitleFromTableView:String?
    var postTimeFromTableView:String?
    var postContentFromTableView:String?
    var authPhotoFromTableView:String!
    var childIDFromTableView:String?
    var authUID:String?
    var currerUID:String?
    
    var responseReviews:[ResponseItem] = [ResponseItem]()
    var replyPhoto:[UIImage] = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("auth photo: \(authPhotoFromTableView)")
        detailTableView.delegate = self
        detailTableView.dataSource = self
        if let user = Auth.auth().currentUser{
            currerUID = user.uid
        }
//        detailTableView.rowHeight = UITableViewAutomaticDimension
//        detailTableView.estimatedRowHeight = 200


        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("run viewWillAppear")
        //Download response
        if let childID = childIDFromTableView {
            print("run in download response data")
            Database.database().reference(withPath: "POST/\(childID)/reply").queryOrderedByKey().observe(.value, with: {
                (snapshot) in
                //            print("post count: \(snapshot.value)")
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
                
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if let cellPost = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DetailTableViewCell{
                cellPost.authName.text = authNameFromTableView
                cellPost.postTitle.text = postTitleFromTableView
                cellPost.postTime.text = postTimeFromTableView
                cellPost.postContent.text = postContentFromTableView
                //download photo
                let maxSize:Int64 = 25 * 1024 * 1024
                Storage.storage().reference(forURL: authPhotoFromTableView!).getData(maxSize: maxSize, completion: {
                    (data,error) in
                    if error != nil{
                        print("Photo error")
                        return
                    }
                    guard let imageData = UIImage(data: data!) else { return }
                    DispatchQueue.main.async {
                        cellPost.authPhoto.image = imageData
                    }
                    
                })
                cellPost.postContent.delegate = self
                return cellPost
            }else{
                let cellPost = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cellPost.textLabel?.text = "Error"
                return cellPost
            }
        }else{
            if let cellResponse = tableView.dequeueReusableCell(withIdentifier: "responseCell", for: indexPath) as? ResponseTableViewCell{
                cellResponse.replyName.text = self.responseReviews[indexPath.row].reply
                cellResponse.replyTime.text = self.responseReviews[indexPath.row].datetime
                cellResponse.replyContent.text = self.responseReviews[indexPath.row].content
                //download photo
                let maxSize:Int64 = 25 * 1024 * 1024
                Storage.storage().reference(forURL: self.responseReviews[indexPath.row].photoURL).getData(maxSize: maxSize, completion: {
                    (data,error) in
                    if error != nil{
                        print("Photo error")
                        return
                    }
                    guard let imageData = UIImage(data: data!) else { return }
                    DispatchQueue.main.async {
                        cellResponse.replyPhoto.image = imageData
                    }
                    
                })
                cellResponse.replyContent.delegate = self
                return cellResponse
            }else{
                let cellResponse = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cellResponse.textLabel?.text = "Error"
                return cellResponse
            }
        }
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goReply" {
//            if let dvc = segue.destination as? ResponseViewController{
//                dvc.childIDFromDetailTableView = self.childIDFromTableView
//            }
//        }
//    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "回應"
        }else{
            return ""
        }
    }
    
    @IBAction func actionMenu(_ sender: UIBarButtonItem) {
        let actionController = UIAlertController(title: "更多動作", message: "請選擇要執行的動作", preferredStyle: .actionSheet)
        let replyAction = UIAlertAction(title: "回應文章", style: .default){
            (action:UIAlertAction) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "replyPost") as! ResponseViewController
            vc.childIDFromDetailTableView = self.childIDFromTableView
            self.present(vc, animated: true, completion: nil)
        }
        let updateAction = UIAlertAction(title: "編輯文章", style: .default){
            (action:UIAlertAction) in
            print("delete post in show post page")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "updatePost") as! UpdateViewController
            vc.titleFromDetailTableView = self.postTitleFromTableView
            vc.contentFromDetailTableView = self.postContentFromTableView
            vc.childIDFromDetailTableView = self.childIDFromTableView
            self.present(vc, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        if currerUID == authUID{
            actionController.addAction(replyAction)
            actionController.addAction(updateAction)
            actionController.addAction(cancelAction)
        }else{
            actionController.addAction(replyAction)
            actionController.addAction(cancelAction)
        }
        self.present(actionController, animated: true, completion: nil)
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
//        let currentOffset = detailTableView.contentOffset
//        UIView.setAnimationsEnabled(false)
//        detailTableView.beginUpdates()
//        detailTableView.endUpdates()
//        UIView.setAnimationsEnabled(true)
//        detailTableView.setContentOffset(currentOffset, animated: false)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
