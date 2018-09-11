//
//  ResponseViewController.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/8/31.
//  Copyright © 2018年 TSL. All rights reserved.
//  此頁面負責讓使用者輸入要回應貼文的內容。

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ResponseViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var replyContent: UITextView!
    
    //declaration
    var childIDFromDetailTableView:String?
    var ref:DatabaseReference!
    var replyName:String = " "
    var photoURL:String = " "
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //下載回應者名稱（此段可省略，因為已改成透過uid抓取作者名稱與照片）
        if let user = Auth.auth().currentUser{
            self.uid = user.uid
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Name")
            ref.observe(.value, with: {
                (snapshot) in
                if let name = snapshot.value{
                    let showName = name as! String
                    //                    print(showName)
                    self.replyName = showName
                }else{
                    self.replyName = "User"
                }
            })//End of download name
            
            //下載回應者照片（此段可省略，因為已改成透過uid抓取作者名稱與照片）
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Photo")
            ref.observe(.value, with: {
                (snapshot) in
                if let photo = snapshot.value{
                    let showPhoto = photo as! String
                    //                    print(showName)
                    self.photoURL = showPhoto
                }else{
                    self.photoURL = ""
                }
            })//End of download photo
        }//End of currentUser
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //送出回應的按鈕
    @IBAction func replyPost(_ sender: UIButton) {
        if let content = replyContent.text{
            let timeNow = getDateTimeNow()
            if let childID = childIDFromDetailTableView{
                let reference = Database.database().reference().child("POST/\(childID)/reply")
                let childRef = reference.childByAutoId()
                
                //完成寫入回應到資料庫的前置作業
                var reply:[String : AnyObject] = [String : AnyObject]()
                reply["childId"] = childRef.key as AnyObject
                reply["content"] = "\(content)" as AnyObject
                reply["dateTime"] = "\(timeNow)" as AnyObject
                reply["reply"] = "\(replyName)" as AnyObject
                reply["photoURL"] = "\(photoURL)" as AnyObject
                reply["userUID"] = "\(uid)" as AnyObject
                
                //將回應寫入至資料庫
                let replyReference = reference.child(childRef.key)
                replyReference.updateChildValues(reply){
                    (error,ref) in
                    if error != nil{
                        print(error?.localizedDescription)
                        return
                    }
                    print(ref.description())
                }
                print("Success reply")
                popAlert(titleStr: "回應成功", messageStr: "已成功回應貼文")
            }//End of childID
        }//End of content
    }
    
    //返回按鈕
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //取得發文當下日期時間
    func getDateTimeNow() -> String{
        let now = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        let timeNow = dateFormat.string(from: now)
        return timeNow
    }
    //警告控制器
    func popAlert(titleStr:String, messageStr:String){
        let alertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel){
            (action:UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    //點擊空白區域即可收回鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
