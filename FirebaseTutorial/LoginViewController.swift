//
//  LoginViewController.swift
//  FirebaseTutorial
//
//  Created by James Dacombe on 16/11/2016.
//  Updated by TSL on 10/09/2018
//  Copyright © 2016 AppCoda. All rights reserved.
//  此頁面負責使用者登入

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //declaration
    var uid = ""
    let urlSession = URLSession(configuration: .default)
    let uniqueString = NSUUID().uuidString
    
    //一般 E-Mail 登入按鈕
    @IBAction func loginAction(_ sender: AnyObject) {
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            // 提示用戶是不是忘記輸入 textfield ？
            popAlert(titleStr: "錯誤", messageStr: "請輸入帳號或密碼")
        }else{
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    //登入成功，顯示個人首頁
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                }else{
                    // 提示用戶從 firebase 返回了一個錯誤。
                    self.popAlert(titleStr: "Error", messageStr: "Error\(String(describing: error?.localizedDescription))")
                }
            }//End of signIn
        }
    }//End of loginAction
    
    //FaceBook 登入按鈕
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
                                        
                                        let storageRef = Storage.storage().reference().child("\(self.uniqueString).jpg")
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
                                                    })//End of setValue
                                                }//End of uploadImageURL
                                            })//End of putData
                                        } //end of photo
                                    }//End of downloadImage
                                }catch{
                                    print("downloadImage Error")
                                }
                            }//End of okURL
                        })//End of task
                        task.resume()
                    }
                    //將個人資料一併寫入資料庫
                    Database.database().reference(withPath:"ID/\(self.uid)/Profile/Name").setValue(user.displayName)
                    Database.database().reference(withPath:"ID/\(self.uid)/Profile/Birthday").setValue("")
                    Database.database().reference(withPath:"ID/\(self.uid)/Profile/Introduction").setValue("")
                    Database.database().reference(withPath:"ID/\(self.uid)/Profile/PhotoName").setValue(self.uniqueString)
                    Database.database().reference(withPath:"ID/\(self.uid)/Status").setValue("Yes")
                }
                //登入成功，顯示個人首頁
                let time:TimeInterval = 2.0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time){
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                }
            })
        })
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
