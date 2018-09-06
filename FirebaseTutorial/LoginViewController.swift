//
//  LoginViewController.swift
//  FirebaseTutorial
//
//  Created by James Dacombe on 16/11/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FBSDKLoginKit

class LoginViewController: UIViewController {

    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var uid = ""
    let urlSession = URLSession(configuration: .default)

    //Login Action
    @IBAction func loginAction(_ sender: AnyObject) {
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            
            // 提示用戶是不是忘記輸入 textfield ？
            popAlert(titleStr: "Error", messageStr: "Please enter an email and password.")
        } else {
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    
                    // 登入成功，打印 ("You have successfully logged in")
                    
                    //Go to the HomeViewController if the login is sucessful
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    
                    // 提示用戶從 firebase 返回了一個錯誤。
                    self.popAlert(titleStr: "Error", messageStr: "Error\(String(describing: error?.localizedDescription))")
                }
            }
        }
    }
    
    @IBAction func facebookLogin(_ sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile","email"], from: self, handler: {
        (result,error) in
            if let errorToken = error{
                self.popAlert(titleStr: "Error", messageStr: "Fail to get access token")
                return
            }
            guard let accessToken = FBSDKAccessToken.current() else {
                self.popAlert(titleStr: "Error", messageStr: "Fail to get access token")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            Auth.auth().signIn(with: credential, completion: {
                (user,error) in
                if let errorLogin = error{
                    print(error?.localizedDescription)
                    self.popAlert(titleStr: "Login Error", messageStr: "Somethings error")
                    return
                }
                if let user = Auth.auth().currentUser{
                    self.uid = user.uid
                    if let downloadURL = user.photoURL{
                        let task = self.urlSession.downloadTask(with: downloadURL, completionHandler: {
                            (url,response,error) in
                            if error != nil{
                                print("photo download fail")
                                return
                            }
                            if let okURL = url{
                                do{
                                    if let downloadImage = UIImage(data: try Data(contentsOf: okURL)){
                                        let uniqueString = NSUUID().uuidString
                                        let storageRef = Storage.storage().reference().child("\(uniqueString).png")
                                        if let uploadData = UIImagePNGRepresentation(downloadImage){
                                            storageRef.putData(uploadData, metadata: nil, completion: {
                                                (data,error) in
                                                if error != nil{
                                                    print("Error: \(error!.localizedDescription)")
                                                    return
                                                }
                                                if let uploadImageURL = data?.downloadURL()?.absoluteString{
                                                    print("Photo: \(uploadImageURL)")
                                                    let databaseRef = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Photo")
                                                    
                                                    databaseRef.setValue(uploadImageURL, withCompletionBlock: {
                                                        (error,dataRef) in
                                                        if error != nil{
                                                            print("Database Error : \(error!.localizedDescription)")
                                                        }else{
                                                            print("Success")
                                                        }
                                                    })
                                                }
                                            })
                                        } //end of photo
                                    }
                                }catch{
                                    
                                }
                            }
                        })
                        task.resume()
                    }
                    
                    Database.database().reference(withPath:"ID/\(self.uid)/Profile/Name").setValue(user.displayName)
                    Database.database().reference(withPath:"ID/\(self.uid)/Profile/Birthday").setValue("")
                    Database.database().reference(withPath:"ID/\(self.uid)/Profile/Introduction").setValue("")
                }
                
                let time:TimeInterval = 2.0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time){
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                
                
                }
            })
        })
    }
    
    func popAlert(titleStr:String, messageStr:String){
        let alertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
//    func delayTime(time: TimeInterval,page: String){
////        let time:TimeInterval = 2.0
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time){
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: page)
//            self.present(vc!,animated: true,completion: nil)
//        }
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
