//
//  ProfileEditViewController.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/9/5.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ProfileEditViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var editName: UITextField!
    @IBOutlet weak var editBirthday: UITextField!
    @IBOutlet weak var introductionText: UITextView!
    
    var formater:DateFormatter! = nil
    var uid = ""
    var imageFileName:String?
    var birthday = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBirthday()
        if let user = Auth.auth().currentUser{
            self.uid = user.uid
            
            var ref:DatabaseReference!
            //
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
                
            })
            //
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Birthday")
            ref.observe(.value, with: {
                (snapshot) in
                if let birthday = snapshot.value{
                    let showBirthday = birthday as! String
                    self.editBirthday.text = showBirthday
                }else{
                    self.editBirthday.text = " "
                }
            })
            //
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Introduction")
            ref.observe(.value, with: {
                (snapshot) in
                if let introduction = snapshot.value{
                    let showIntroduction = introduction as! String
                    self.introductionText.text = showIntroduction
                }else{
                    self.introductionText.text = ""
                }
            })
            //
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
                    })
                }else{
                    self.imageFileName = ""
                }
            })
            //
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/PhotoName")
            ref.observe(.value, with: {
                (snapshot) in
                if let photoName = snapshot.value{
                    let name = photoName as! String
                    self.imageFileName = name
                }else{
                    self.imageFileName = ""
                }
            })
        }
        
        
    }
    
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
    @IBAction func sentEdit(_ sender: UIButton) {
        //photo update
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
                })
            }else{
                print("uploadData fail")
            }
        }
        Database.database().reference(withPath:"ID/\(self.uid)/Profile/Name").setValue(self.editName.text)
        Database.database().reference(withPath:"ID/\(self.uid)/Profile/Birthday").setValue(birthday)
        Database.database().reference(withPath:"ID/\(self.uid)/Profile/Introduction").setValue(introductionText.text)
        popAlert(titleStr: "個人資料", messageStr: "個人資料已更新完畢")
    }
    
    
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
    
    func datePickerChanged(datePicker:UIDatePicker){
        let myTextField = self.view.viewWithTag(200) as? UITextField
        myTextField?.text = formater.string(from: datePicker.date)
//        print("birthday: \(myTextField?.text)")
        self.birthday = (myTextField?.text)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
            editImage.image = selectedImage
            
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
