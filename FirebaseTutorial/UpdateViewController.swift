//
//  UpdateViewController.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/9/2.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UpdateViewController: UIViewController {
    @IBOutlet weak var updateTitle: UITextField!
    @IBOutlet weak var updateContent: UITextView!
    
    var titleFromDetailTableView:String?
    var contentFromDetailTableView:String?
    var childIDFromDetailTableView:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitle.text = titleFromDetailTableView
        updateContent.text = contentFromDetailTableView
        //test
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sentUpdate(_ sender: UIButton) {
        if let childID = childIDFromDetailTableView{
            Database.database().reference(withPath:"POST/\(childID)/title").setValue(updateTitle.text)
            Database.database().reference(withPath:"POST/\(childID)/content").setValue(updateContent.text)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
            present(vc!, animated: true, completion: nil)
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
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
