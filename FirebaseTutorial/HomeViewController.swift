//
//  HomeViewController.swift
//  FirebaseTutorial
//
//  Created by James Dacombe on 16/11/2016.
//  Updated by TSL on 10/09/2018
//  Copyright © 2016 AppCoda. All rights reserved.
//  此頁面為登入成功後顯示的個人頁面

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class HomeViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var WellcomeLable: UILabel!
    @IBOutlet weak var accountPhoto: UIImageView!
    
    //declaration
    var uid = ""
    var ref:DatabaseReference!
    
    //下載並顯示個人資料
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let user = Auth.auth().currentUser {
            self.uid = user.uid
            //下載使用者名稱
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Name")
            ref.observe(.value, with: {
                (snapshot) in
                if let name = snapshot.value{
                    let showName = name as! String
                    print(showName)
                    self.WellcomeLable.text = "Hello \(showName)"
                    self.WellcomeLable.isHidden = false
                }else{
                    self.WellcomeLable.text = "Hello User"
                    self.WellcomeLable.isHidden = false
                }
                
            })//End of download user name
            
            //下載使用者圖片
            ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Photo")
            ref.observe(.value, with: {
                (snapshot) in
                let url = snapshot.value as! String
                let maxSize:Int64 = 25 * 1024 * 1024
                Storage.storage().reference(forURL: url).getData(maxSize: maxSize, completion: {
                    (data,error) in
                    if error != nil{
                        print("Photo error")
                        return
                    }
                    guard let imageData = UIImage(data: data!) else { return }
                    DispatchQueue.main.async {
                        self.accountPhoto.image = imageData
                    }
                    
                })//End of getData
            })//End of download user photo
        }//End of currentUser
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //編輯個人資料的按鈕
    @IBAction func editProfile(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "editProfile")
        present(vc!, animated: true, completion: nil)
    }
    
    //登出的按鈕
    @IBAction func logOutAction(sender: AnyObject) {
        if Auth.auth().currentUser != nil{
            do{
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp")
                present(vc,animated: true,completion: nil)
                
            }catch let error as NSError {
                print(error.localizedDescription)
            }
        }//End of currentUser
    }//End of logOutAction
}
