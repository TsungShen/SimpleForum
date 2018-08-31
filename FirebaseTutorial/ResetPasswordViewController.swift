//
//  ResetPasswordViewController.swift
//  FirebaseTutorial
//
//  Created by James Dacombe on 16/11/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import FirebaseAuth


class ResetPasswordViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var emailTextField: UITextField!

    // Reset Password Action
    @IBAction func submitAction(_ sender: AnyObject)
    {
        if emailTextField.text == ""{
            popAlert(titleStr: "Oops", messageStr: "Please enter an email address")
        }else{
            Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!, completion: {
                (error) in
                var title = ""
                var message = ""
                
                if error != nil{
                    title = "Error"
                    message = (error?.localizedDescription)!
                }else{
                    title = "Success!"
                    message = "Password reset email sent"
                    self.emailTextField.text = ""
                }
                self.popAlert(titleStr: "\(title)", messageStr:"\(message)" )
                
            })
        }
    }
    

    func popAlert(titleStr:String, messageStr:String){
        let alertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
