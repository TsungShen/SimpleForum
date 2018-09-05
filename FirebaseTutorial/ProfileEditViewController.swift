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

class ProfileEditViewController: UIViewController {
    @IBOutlet weak var birthTextField: UITextField!
    
    var formater:DateFormatter! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        print("birthday: \(myTextField?.text)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
