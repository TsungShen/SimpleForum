//
//  ResetPasswordViewController.swift
//  FirebaseTutorial
//
//  Created by James Dacombe on 16/11/2016.
//  Updated by TSL on 10/09/2018
//  Copyright © 2016 AppCoda. All rights reserved.
//  此頁面負責密碼重設

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    
    //重設密碼的按鈕
    @IBAction func submitAction(_ sender: AnyObject)
    {
        if emailTextField.text == ""{
            popAlert(titleStr: "Oops", messageStr: "請輸入電子郵件地址")
        }else{
            Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!, completion: {
                (error) in
                var title = ""
                var message = ""
                
                if error != nil{
                    title = "Error"
                    message = (error?.localizedDescription)!
                }else{
                    title = "成功!"
                    message = "密碼重設信件已寄出"
                    self.emailTextField.text = ""
                }
                self.popAlert(titleStr: "\(title)", messageStr:"\(message)" )
            })
        }
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
