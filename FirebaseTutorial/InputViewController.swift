//
//  InputViewController.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/8/24.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class InputViewController: UIViewController {

    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var contentText: UITextView!
    var ref:DatabaseReference!
    let uniqueString = NSUUID().uuidString
    var uid = ""
    var authName:String = "User"
    var photoURL:String = " "
    
    @IBAction func sendOut(_ sender: UIButton) {
        
        if let title = titleText.text, let content = contentText.text{
           let timeNow = getDateTimeNow()
            let reference = Database.database().reference().child("POST")
            let childRef = reference.childByAutoId()
            
            var post:[String : AnyObject] = [String : AnyObject]()
            post["childId"] = childRef.key as AnyObject
            post["title"] = "\(title)" as AnyObject
            post["content"] = "\(content)" as AnyObject
            post["dateTime"] = "\(timeNow)" as AnyObject
            post["auth"] = "\(authName)" as AnyObject
            post["photoURL"] = "\(photoURL)" as AnyObject
            post["userUID"] = "\(uid)" as AnyObject
            
            let postReference = reference.child(childRef.key)
            postReference.updateChildValues(post){
                (error,ref) in
                if error != nil{
                    print(error?.localizedDescription)
                    return
                }
                print(ref.description())
            }
                print("Success input")
                popAlert(titleStr: "新增成功", messageStr: "已成功張貼至討論區")
            
                titleText.text = ""
                contentText.text = ""
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = Auth.auth().currentUser{
            self.uid = user.uid
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Name")
            ref.observe(.value, with: {
                (snapshot) in
                if let name = snapshot.value{
                    let showName = name as! String
//                    print(showName)
                    self.authName = showName
                }else{
                    self.authName = "User"
                }
            })
            //
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
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getDateTimeNow() -> String{
        let now = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        let timeNow = dateFormat.string(from: now)
        return timeNow
    }
    func popAlert(titleStr:String, messageStr:String){
        let alertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
