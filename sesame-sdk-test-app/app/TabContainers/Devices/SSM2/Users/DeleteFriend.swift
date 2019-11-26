//
//  DeleteFriend.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/11/12.
//  Copyright © 2019 Cerberus. All rights reserved.
//


import SesameSDK
import UIKit
class DeleteFriendVC: BaseViewController {
    var sesame: CHSesameBleInterface?

    @IBOutlet weak var friendTable: UITableView!
    var refreshControl:UIRefreshControl = UIRefreshControl()
    var memberList = [Client]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Members"

        friendTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        friendTable.tableFooterView = UIView(frame: .zero)

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.friendTable.addSubview(refreshControl)

    }

    @objc func refresh(sender:AnyObject) {

    }
}//end class
extension DeleteFriendVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FRCell", for: indexPath) as! FriendCell
        cell.nameLb.text = "\(self.memberList[indexPath.row].nickname ?? "NA")"
        cell.headImg.image = UIImage.makeLetterAvatar(withUsername: "\(self.memberList[indexPath.row].nickname ?? "NA")")
        return cell
    }
}
extension DeleteFriendVC: UITableViewDelegate {


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        L.d(indexPath.section,indexPath.row)

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        let member = self.memberList[indexPath.row]
        if editingStyle == UITableViewCell.EditingStyle.delete {
            self.sesame!.revokeKey(member) { (result) in
                if result.success {
                    CHAccountManager.shared.deviceManager.getDeviceMembers(self.sesame!) { (_, result, users) in
                        if result.success {
                            if let users = users {
                                DispatchQueue.main.async {
                                    self.memberList = users
                                    self.friendTable.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
