//
//  AddFriendVC.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/11/2.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import SesameSDK
import UIKit
class AddFriendVC: BaseViewController {
    var sesame: CHSesameBleInterface?

    @IBOutlet weak var friendTable: UITableView!
    var refreshControl:UIRefreshControl = UIRefreshControl()
    var mFriends = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Friends".localStr
        CHAccountManager.shared.myFriends(){ friends in
            DispatchQueue.main.async {
                L.d("friends",friends)
                self.mFriends = friends
                self.friendTable.reloadData()
            }
        }
        friendTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        friendTable.tableFooterView = UIView(frame: .zero)

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.friendTable.addSubview(refreshControl)

    }

    @objc func refresh(sender:AnyObject) {
        CHAccountManager.shared.myFriends(){ friends in
            DispatchQueue.main.async {
                self.mFriends = friends
                self.friendTable.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
}//end class
extension AddFriendVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mFriends.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        let cell = tableView.dequeueReusableCell(withIdentifier: "FRCell", for: indexPath) as! FriendCell
        cell.nameLb.text = "\(self.mFriends[indexPath.row].nickname)"
        cell.headImg.image = UIImage.makeLetterAvatar(withUsername: "\(self.mFriends[indexPath.row].nickname)")

        return cell
    }
}
extension AddFriendVC: UITableViewDelegate {


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        ViewHelper.showLoadingInView(view: self.view)

        sesame?.addKeyByFriend(accessLevel: .manager,uuidStr: self.mFriends[indexPath.row].id, { (result, _) in
            if result.success {
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "unfriend"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            CHAccountManager.shared.unfriend(fdId: self.mFriends[indexPath.row].id){ isSuccess in
                DispatchQueue.main.async {
                    if(isSuccess){
                        self.mFriends.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                    }
                }
            }
        }
    }
}
