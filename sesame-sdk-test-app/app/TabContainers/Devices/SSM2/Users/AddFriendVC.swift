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
    var refreshControl:UIRefreshControl = UIRefreshControl()
    var mFriends = [CHFriend](){
        didSet {
            if(self.mFriends.count == 0) {                          self.friendTable.setEmptyMessage("No Friends".localStr)//todo i18n
            }else{
                self.friendTable.restore()
            }
        }
    }
    @IBOutlet weak var friendTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts".localStr
        CHAccountManager.shared.myFriends(){ friends in
            DispatchQueue.main.async {
                self.mFriends = friends.sorted { $0.nickname! < $1.nickname!}
                self.friendTable.reloadData()
                self.refreshControl.endRefreshing()

            }
        }
        friendTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        friendTable.tableFooterView = UIView(frame: .zero)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localStr)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.friendTable.addSubview(refreshControl)
    }

    @objc func refresh(sender:AnyObject) {
        CHAccountManager.shared.myFriends(){ friends in
            DispatchQueue.main.async {
                self.mFriends = friends.sorted { $0.nickname! < $1.nickname!}
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
        cell.nameLb.text = "\(self.mFriends[indexPath.row].nickname ?? "-")"
        cell.headImg.image = UIImage.makeLetterAvatar(withUsername: "\(self.mFriends[indexPath.row].givenname ?? "-")")
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
}
extension AddFriendVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: self.mFriends[indexPath.row].nickname, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel".localStr, style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Add Member".localStr, style: .destructive){
            UIAlertAction in
            ViewHelper.showLoadingInView(view: self.view)

            self.sesame?.addKeyByFriend(accessLevel: .manager,uuidStr: self.mFriends[indexPath.row].id!.uuidString, { (result, _) in
                if result.success {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
extension AddFriendVC{
    @objc private func handleRightBarButtonTapped(_ sender: Any) {
        (self.tabBarController as! GeneralTabViewController).scanQR(from: "addSesame"){ (name) in
            DispatchQueue.main.async {
                ViewHelper.showLoadingInView(view: self.view)
            }
            self.sesame?.addKeyByFriend(accessLevel: .manager,uuidStr: name, { (result, _) in
                if result.success {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let rightButtonItem = UIBarButtonItem(image: UIImage.SVGImage(named: isDarkMode() ? "icons_filled_add-friends_black":"icons_filled_add-friends"), style: .done, target: self, action: #selector(handleRightBarButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightButtonItem
    }
}
