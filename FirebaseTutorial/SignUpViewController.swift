//
//  SignUpViewController.swift
//  FirebaseTutorial
//
//  Created by James Dacombe on 16/11/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

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
    
    var uid = ""
//    let uniqueString = NSUUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
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
        })
        let imageFromCameraAction = UIAlertAction(title: "相機", style: .default, handler: {
            (void) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            (void) in
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        })
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        present(imagePickerAlertController, animated: true, completion: nil)
        
    }
    
    //Sign Up Action for email
    @IBAction func createAccountAction(_ sender: AnyObject) {
        
        if emailTextField.text == nil || passwordTextField.text == "" || nameTextField.text == "" {
            popAlert(titleStr: "Error", messageStr: "Please enter your email")
        }else{
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    print("You have successfully signed up")
                    if let user = Auth.auth().currentUser{
                        self.uid = user.uid
                        
                        Database.database().reference(withPath:"ID/\(self.uid)/Profile/safety-Check").setValue("ON")
                        Database.database().reference(withPath:"ID/\(self.uid)/Profile/Name").setValue(self.nameTextField.text)
                        print("Strat Photo Handle")
                        let uniqueString = NSUUID().uuidString
                        let storageRef = Storage.storage().reference().child("Profile/Photo\(uniqueString).jpg")
                        //reSize image
//                        let resizePhoto = self.resizeImage(originalImg: self.accountImage.image!)
                        
                        //try UIImageJPEGRepresentation
                        //if let uploadData = UIImagePNGRepresentation(resizePhoto){
                        if let uploadData = UIImageJPEGRepresentation(self.accountImage.image!,0.8){
                            print("Success convert to data")

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
                                    let databaseRef = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Photo")

                                    databaseRef.setValue(uploadImageURL, withCompletionBlock: {
                                        (error,dataRef) in
                                        if error != nil{
                                            print("Database Error : \(error!.localizedDescription)")
                                        }else{
                                            print("Success")
                                        }
                                    })
                                }else{
                                    print("uploadImageURL null")
                                }
                            })
                        }else{
                            print("uploadData fail")
                        }
                        
                        //end of photo
                        
                    }
                    //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                    
                    let time:TimeInterval = 1.5
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time){
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                        self.present(vc!, animated: true, completion: nil)
                        
                        
                    }
                    
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
//                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    self.popAlert(titleStr: "Error", messageStr: "Fail")
                }
            }
        }
      
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        var selectedImageFromPicker: UIImage?
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = pickedImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            accountImage.image = selectedImage
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(originalImg:UIImage) -> UIImage{
        
        //prepare constants
        let width = originalImg.size.width
        let height = originalImg.size.height
        let scale = width/height
        
        var sizeChange = CGSize()
        
        if width <= 1280 && height <= 1280{ //a，图片宽或者高均小于或等于1280时图片尺寸保持不变，不改变图片大小
            return originalImg
        }else if width > 1280 || height > 1280 {//b,宽或者高大于1280，但是图片宽度高度比小于或等于2，则将图片宽或者高取大的等比压缩至1280
            
            if scale <= 2 && scale >= 1 {
                let changedWidth:CGFloat = 1280
                let changedheight:CGFloat = changedWidth / scale
                sizeChange = CGSize(width: changedWidth, height: changedheight)
                
            }else if scale >= 0.5 && scale <= 1 {
                
                let changedheight:CGFloat = 1280
                let changedWidth:CGFloat = changedheight * scale
                sizeChange = CGSize(width: changedWidth, height: changedheight)
                
            }else if width > 1280 && height > 1280 {//宽以及高均大于1280，但是图片宽高比大于2时，则宽或者高取小的等比压缩至1280
                
                if scale > 2 {//高的值比较小
                    
                    let changedheight:CGFloat = 1280
                    let changedWidth:CGFloat = changedheight * scale
                    sizeChange = CGSize(width: changedWidth, height: changedheight)
                    
                }else if scale < 0.5{//宽的值比较小
                    
                    let changedWidth:CGFloat = 1280
                    let changedheight:CGFloat = changedWidth / scale
                    sizeChange = CGSize(width: changedWidth, height: changedheight)
                    
                }
            }else {//d, 宽或者高，只有一个大于1280，并且宽高比超过2，不改变图片大小
                return originalImg
            }
        }
        
        UIGraphicsBeginImageContext(sizeChange)
        
        //draw resized image on Context
//        originalImg.draw(in: CGRect(0, 0, sizeChange.width, sizeChange.height))
        
        //create UIImage
        let resizedImg = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resizedImg!
        
    }
    

    
}


