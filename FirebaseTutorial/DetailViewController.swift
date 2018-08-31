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
    var authPhoto:UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("auth photo: \(authPhotoFromTableView)")
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.rowHeight = UITableViewAutomaticDimension
        detailTableView.estimatedRowHeight = 200

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
                self.authPhoto = imageData
                print("image data: \(self.authPhoto)")
            }

        })
        
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
        }else {
            return 5
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var returnCell:UITableViewCell?
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DetailTableViewCell{
            if indexPath.section == 0 {
                cell.authName.text = authNameFromTableView
                cell.postTitle.text = postTitleFromTableView
                cell.postTime.text = postTimeFromTableView
                cell.postContent.text = postContentFromTableView
                
                let time:TimeInterval = 1.0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time){
                    cell.authPhoto.image = self.authPhoto
                }
                cell.postContent.delegate = self
                returnCell = cell
//                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "responseCell", for: indexPath)
                
//                cell.textLabel?.text = "Response Test"
                returnCell = cell
//                return cell!
            }
//            return cell
        }
        return returnCell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goReply" {
            if let dvc = segue.destination as? ResponseViewController{
                dvc.childIDFromDetailTableView = self.childIDFromTableView
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "回應"
        }else{
            return ""
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let currentOffset = detailTableView.contentOffset
        UIView.setAnimationsEnabled(false)
        detailTableView.beginUpdates()
        detailTableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        detailTableView.setContentOffset(currentOffset, animated: false)
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return detailTableView.rowHeight
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
