//
//  ShowTableViewController.swift
//  FirebaseTutorial
//
//  Created by 呂宗昇 on 2018/8/25.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class ShowTableViewController: UITableViewController {
    
    var postReviews: [PostItem] = [PostItem]()
    var childID: String = ""

    @IBOutlet weak var showTitle: UILabel!
    @IBOutlet weak var showAuth: UILabel!
    @IBOutlet weak var showDateTime: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        Database.database().reference(withPath: "POST").queryOrderedByKey().observe(.value, with: {
            (snapshot) in
//            print("post count: \(snapshot.value)")
            if snapshot.childrenCount > 0{
                var dataList: [PostItem] = [PostItem]()
                
                for item in snapshot.children{
                    let data = PostItem(snapshot: item as! DataSnapshot)
                    dataList.append(data)
                }
                self.postReviews = dataList.reversed()
//                print("dataList: \(dataList)")
                self.tableView.reloadData()
                
            }
            
            
            
//            if let dictionaryData = snapshot.value as? [String : AnyObject]{
//                print(dictionaryData)
//            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.postReviews.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? ShowTableViewCell
        cell?.showTitle.text = postReviews[indexPath.row].title
        cell?.showAuth.text = postReviews[indexPath.row].auth
        cell?.showDateTime.text = postReviews[indexPath.row].datetime

        // Configure the cell...

        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            if let dvc = segue.destination as? DetailViewController{
                if let selectRow = tableView.indexPathForSelectedRow?.row{
                    dvc.accountPhotoFromTableView = postReviews[selectRow].auth
                    dvc.authNameFromTableView = postReviews[selectRow].auth
                    dvc.postTitleFromTableView = postReviews[selectRow].title
                    dvc.postTimeFromTableView = postReviews[selectRow].datetime
                    dvc.postContentFromTableView = postReviews[selectRow].content
                    dvc.authPhotoFromTableView = postReviews[selectRow].photoURL
                    dvc.childIDFromTableView = postReviews[selectRow].childId
                    

                }
            }
        }
    }
    
    
//    func downloadPhoto(){
//        var ref:DatabaseReference!
//        //download photo
//        let maxSize:Int64 = 25 * 1024 * 1024
//        
//        Storage.storage().reference(forURL: postReviews[]).getData(maxSize: maxSize, completion: {
//            (data,error) in
//            if error != nil{
//                print("Photo error")
//                return
//            }
//            guard let imageData = UIImage(data: data!) else { return }
//            DispatchQueue.main.async {
//                self.authPhoto = imageData
//                print("image data: \(self.authPhoto)")
//            }
//            
//        })
//    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
