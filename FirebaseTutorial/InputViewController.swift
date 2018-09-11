//
//  InputViewController.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/8/24.
//  Copyright © 2018年 TSL. All rights reserved.
//  此頁面負責新增貼文的輸入畫面

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class InputViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var contentText: UITextView!
    
    //declaration
    var ref:DatabaseReference!
    let uniqueString = NSUUID().uuidString
    var uid = ""
    var authName:String = "User"
    var photoURL:String = ""

    //先取得作者資料
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = Auth.auth().currentUser{
            self.uid = user.uid
            //下載作者名稱（此段可省略，因為已改成透過uid抓取作者名稱與照片）
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Name")
            ref.observe(.value, with: {
                (snapshot) in
                if let name = snapshot.value{
                    let showName = name as! String
                    self.authName = showName
                }else{
                    self.authName = "User"
                }
            })//End of download name
            
            //下載作者照片（此段可省略，因為已改成透過uid抓取作者名稱與照片）
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Photo")
            ref.observe(.value, with: {
                (snapshot) in
                if let photo = snapshot.value{
                    let showPhoto = photo as! String
                    self.photoURL = showPhoto
                }else{
                    self.photoURL = ""
                }
            })//End of download photo
        }//End of currentUser
    }//End of viewDidLoad()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //送出的按鈕
    @IBAction func sendOut(_ sender: UIButton) {
        if let title = titleText.text, let content = contentText.text{
            let timeNow = getDateTimeNow()
            let reference = Database.database().reference().child("POST")
            let childRef = reference.childByAutoId()
            
            //完成寫入貼文到資料庫的前置作業
            var post:[String : AnyObject] = [String : AnyObject]()
            post["childId"] = childRef.key as AnyObject
            post["title"] = "\(title)" as AnyObject
            post["content"] = "\(content)" as AnyObject
            post["dateTime"] = "\(timeNow)" as AnyObject
            post["auth"] = "\(authName)" as AnyObject
            post["photoURL"] = "\(photoURL)" as AnyObject
            post["userUID"] = "\(uid)" as AnyObject
            
            //將貼文寫入至資料庫
            let postReference = reference.child(childRef.key)
            postReference.updateChildValues(post){
                (error,ref) in
                if error != nil{
                    print(error?.localizedDescription)
                    return
                }
                print(ref.description())
            }//End of updateChildValues
            print("Success input")
            popAlert(titleStr: "新增成功", messageStr: "已成功張貼至討論區")
            titleText.text = ""
            contentText.text = ""
        }
    }//End of sendOut
    
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
