//
//  HomeViewController.swift
//  FirebaseTutorial
//
//  Created by James Dacombe on 16/11/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class HomeViewController: UIViewController {

    @IBOutlet weak var WellcomeLable: UILabel!
    @IBOutlet weak var accountPhoto: UIImageView!
    
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = Auth.auth().currentUser {
            self.uid = user.uid
            
//            print(user.email!)
//            print("uid: \(user.uid)")
            var ref:DatabaseReference!
            //
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
                
            })
            //
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
                    
                })
            })
            //
            ref = Database.database().reference(withPath: "POST")
            ref.observe(.value, with: {
                (snapshot) in
                if let profile = snapshot.value{
                    var profileArray:Any = []
                    profileArray = profile
                    print(profileArray)
                    
                }else{
                    
                }
                
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editProfile(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "editProfile")
        present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func logOutAction(sender: AnyObject) {
        if Auth.auth().currentUser != nil{
            do{
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp")
                present(vc,animated: true,completion: nil)
                
            }catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}
