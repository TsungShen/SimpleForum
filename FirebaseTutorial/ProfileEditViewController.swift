//
//  ProfileEditViewController.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/9/5.
//  Copyright © 2018年 TSL. All rights reserved.
//  此頁面負責讓使用者編輯個人資料。

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ProfileEditViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Outlets
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var editName: UITextField!
    @IBOutlet weak var editBirthday: UITextField!
    @IBOutlet weak var introductionText: UITextView!
    
    //declaration
    var formater:DateFormatter! = nil
    var uid = ""
    var imageFileName:String?
    var birthday = ""
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //從DatePicker取得使用者輸入的生日。
        getBirthday()
        
        if let user = Auth.auth().currentUser{
            self.uid = user.uid
            
            //下載使用者名稱
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Name")
            ref.observe(.value, with: {
                (snapshot) in
                if let name = snapshot.value{
                    let showName = name as! String
                    print(showName)
                    self.editName.text = showName
                }else{
                    self.editName.text = " "
                }
                
            })//End of download name
            
            //下載使用者生日
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Birthday")
            ref.observe(.value, with: {
                (snapshot) in
                if let birthday = snapshot.value{
                    let showBirthday = birthday as! String
                    self.editBirthday.text = showBirthday
                }else{
                    self.editBirthday.text = " "
                }
            })//End of download birthday
            
            //下載使用者個人簡介
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Introduction")
            ref.observe(.value, with: {
                (snapshot) in
                if let introduction = snapshot.value{
                    let showIntroduction = introduction as! String
                    self.introductionText.text = showIntroduction
                }else{
                    self.introductionText.text = ""
                }
            })//End of Introduction
            
            //下載使用者照片
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Photo")
            ref.observe(.value, with: {
                (snapshot) in
                if let photo = snapshot.value{
                    let showPhoto = photo as! String
                    self.imageFileName = showPhoto
                    //download photo
                    let maxSize:Int64 = 25 * 1024 * 1024
                    Storage.storage().reference(forURL: showPhoto).getData(maxSize: maxSize, completion: {
                        (data,error) in
                        if error != nil{
                            print("Photo error")
                            return
                        }
                        guard let imageData = UIImage(data: data!) else { return }
                        DispatchQueue.main.async {
                            self.editImage.image = imageData
                        }
                    })//End of download photo data
                }else{
                    self.imageFileName = ""
                }
            })//End of download photo url
            
            //下載使用者照片檔名
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/PhotoName")
            ref.observe(.value, with: {
                (snapshot) in
                if let photoName = snapshot.value{
                    let name = photoName as! String
                    self.imageFileName = name
                }else{
                    self.imageFileName = ""
                }
            })//End of download PhotoName
        }//End of currentUser
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //選擇圖片的按鈕
    @IBAction func uploadPhoto(_ sender: UIButton) {
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
    
    //送出按鈕
    @IBAction func sentEdit(_ sender: UIButton) {
        //把照片用原來的檔名上傳
        if let fileName = imageFileName{
            let storageRef = Storage.storage().reference(withPath: "Profile/Photo\(fileName).jpg")
            if let uploadData = UIImageJPEGRepresentation(self.editImage.image!,0.8){
                print("Success convert to data")
                storageRef.putData(uploadData, metadata: nil, completion: {
                    (data,error1) in
                    print("run in putdata")
                    if error1 != nil {
                        print("error in putdata")
                        print("Error: \(error1!.localizedDescription)")
                        return
                    }
                })//End of putData
            }else{
                print("uploadData fail")
            }
        }//End of fileName
        //把更新後的個人資料寫回資料庫
        Database.database().reference(withPath:"ID/\(self.uid)/Profile/Name").setValue(self.editName.text)
        Database.database().reference(withPath:"ID/\(self.uid)/Profile/Birthday").setValue(birthday)
        Database.database().reference(withPath:"ID/\(self.uid)/Profile/Introduction").setValue(introductionText.text)
        popAlert(titleStr: "個人資料", messageStr: "個人資料已更新完畢")
    }
    
    //返回按鈕
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //設定 DataPicker
    func getBirthday(){
        formater = DateFormatter()
        formater.dateFormat = "yyyy年MM月dd日"
        
        let birthDatePicker = UIDatePicker()
        birthDatePicker.datePickerMode = .date
        birthDatePicker.date = NSDate() as Date
        
        birthDatePicker.addTarget(self, action: #selector(ProfileEditViewController.datePickerChanged), for: .valueChanged)
        birthTextField.inputView = birthDatePicker
        birthTextField.tag = 200
    }
    //取得 DataPicker 的數值
    func datePickerChanged(datePicker:UIDatePicker){
        let myTextField = self.view.viewWithTag(200) as? UITextField
        myTextField?.text = formater.string(from: datePicker.date)
        self.birthday = (myTextField?.text)!
    }
    
    //警告控制器
    func popAlert(titleStr:String, messageStr:String){
        let alertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel){
            (action:UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
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
            editImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
