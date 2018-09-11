//
//  SignUpViewController.swift
//  FirebaseTutorial
//
//  Created by James Dacombe on 16/11/2016.
//  Updated by TSL on 10/09/2018
//  Copyright © 2016 AppCoda. All rights reserved.
//  此頁面負責使用者註冊
//  prepare push on github

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var accountImage: UIImageView!
    
    //declaration
    var uid = ""
    let uniqueString = NSUUID().uuidString
   
    //選擇圖片的按鈕
    @IBAction func uploadImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let imagePickerAlertController = UIAlertController(title: "上傳圖片", message: "請選擇要上傳的圖片", preferredStyle: .actionSheet)
        
        let imageFromLibAction = UIAlertAction(title: "照片圖庫", style: .default, handler: {
            (void) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        })//End of imageFromLibAction
        let imageFromCameraAction = UIAlertAction(title: "相機", style: .default, handler: {
            (void) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        })//End of imageFromCameraAction
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            (void) in
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        })//End of cancelAction
        
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        present(imagePickerAlertController, animated: true, completion: nil)
        
    }
    
    //利用E-mail註冊帳號的按鈕
    @IBAction func createAccountAction(_ sender: AnyObject) {
        if emailTextField.text == nil || passwordTextField.text == nil || nameTextField.text == nil || accountImage.image == nil {
            popAlert(titleStr: "錯誤", messageStr: "請將資料填寫完整")
        }else{
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
                (user, error) in
                
                if error == nil {
                    print("You have successfully signed up")
                    if let user = Auth.auth().currentUser{
                        self.uid = user.uid
                        //將個人資料一併寫入資料庫
                        Database.database().reference(withPath:"ID/\(self.uid)/Profile/Name").setValue(self.nameTextField.text)
                        Database.database().reference(withPath:"ID/\(self.uid)/Profile/Birthday").setValue("")
                        Database.database().reference(withPath:"ID/\(self.uid)/Profile/Introduction").setValue("")
                        Database.database().reference(withPath:"ID/\(self.uid)/Profile/PhotoName").setValue(self.uniqueString)
                        Database.database().reference(withPath:"ID/\(self.uid)/Status").setValue("Yes")
                        //進行上傳圖片前置作業
                        print("Strat Photo Handle")
                        let storageRef = Storage.storage().reference().child("Profile/Photo\(self.uniqueString).jpg")
                        //調整圖片大小
                        if let uploadData = UIImageJPEGRepresentation(self.accountImage.image!,0.8){
                            print("Success convert to data")
                            //正式上傳
                            storageRef.putData(uploadData, metadata: nil, completion: {
                                (data,error1) in
                                print("run in putdata")
                                if error1 != nil {
                                    print("error in putdata")
                                    print("Error: \(error1!.localizedDescription)")
                                    return
                                }
                                if let uploadImageURL = data?.downloadURL()?.absoluteString{
                                    print("Success get url")
                                    print("Photo: \(uploadImageURL)")
                                    //將圖片儲存位置寫進資料庫
                                    let databaseRef = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Photo")
                                    databaseRef.setValue(uploadImageURL, withCompletionBlock: {
                                        (error,dataRef) in
                                        if error != nil{
                                            print("Database Error : \(error!.localizedDescription)")
                                        }else{
                                            print("Success")
                                        }
                                    })//End of setValue
                                }else{
                                    print("uploadImageURL null")
                                }
                            })//End of putData
                        }else{
                            print("UIImageJPEGRepresentation fail")
                        }
                    }
                    
                    let time:TimeInterval = 1.5
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time){
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                        self.present(vc!, animated: true, completion: nil)
                    }//End of delay present view
                }else{
                    self.popAlert(titleStr: "Error", messageStr: "Fail")
                }
            }//End of currentUser
        }
    }//End of createAccountAction
    
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
    //圖片選擇的額外方法
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        var selectedImageFromPicker: UIImage?
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = pickedImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            accountImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }//End of imagePickerController
}


