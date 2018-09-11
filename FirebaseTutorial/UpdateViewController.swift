//
//  UpdateViewController.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/9/2.
//  Copyright © 2018年 TSL. All rights reserved.
//  此頁面負責讓貼文作者編輯貼文

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UpdateViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var updateTitle: UITextField!
    @IBOutlet weak var updateContent: UITextView!
    
    //declaration
    var titleFromDetailTableView:String?
    var contentFromDetailTableView:String?
    var childIDFromDetailTableView:String!
    
    //將原來的標題內容顯示在輸入框。
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitle.text = titleFromDetailTableView
        updateContent.text = contentFromDetailTableView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //送出編輯完成的貼文按鈕
    @IBAction func sentUpdate(_ sender: UIButton) {
        if let childID = childIDFromDetailTableView{
            //將編輯完成的內容寫回資料庫。
            Database.database().reference(withPath:"POST/\(childID)/title").setValue(updateTitle.text)
            Database.database().reference(withPath:"POST/\(childID)/content").setValue(updateContent.text)
            
            //編輯完成顯示個人首頁。
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
            present(vc!, animated: true, completion: nil)
        }
    }
    //返回按鈕
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //警告控制器
    func popAlert(titleStr:String, messageStr:String){
        let alertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    //點擊空白區域即可收回鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
