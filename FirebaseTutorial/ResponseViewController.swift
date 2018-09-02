//
//  ResponseViewController.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/8/31.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ResponseViewController: UIViewController {

    @IBOutlet weak var replyContent: UITextView!
    
    var childIDFromDetailTableView:String?
    var ref:DatabaseReference!
    var replyName:String = " "
    var photoURL:String = " "
    var uid = ""
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
                    self.replyName = showName
                }else{
                    self.replyName = "User"
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func replyPost(_ sender: UIButton) {
        if let content = replyContent.text{
            let timeNow = getDateTimeNow()
            if let childID = childIDFromDetailTableView{
                let reference = Database.database().reference().child("POST/\(childID)/reply")
                let childRef = reference.childByAutoId()
                
                var reply:[String : AnyObject] = [String : AnyObject]()
                reply["childId"] = childRef.key as AnyObject
                reply["content"] = "\(content)" as AnyObject
                reply["dateTime"] = "\(timeNow)" as AnyObject
                reply["reply"] = "\(replyName)" as AnyObject
                reply["photoURL"] = "\(photoURL)" as AnyObject
                
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

                //            titleText.text = ""
                //            contentText.text = ""
            }
            }
            

    }
    
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
        let defaultAction = UIAlertAction(title: "OK", style: .cancel){
            (action:UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
