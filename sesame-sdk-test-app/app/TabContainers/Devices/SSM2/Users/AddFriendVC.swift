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
//    var sesame: CHSesameBleInterface?
    var refreshControl:UIRefreshControl = UIRefreshControl()
    var mFriends = [CHFriend](){
        didSet {
            if(self.mFriends.count == 0) {                          self.friendTable.setEmptyMessage("No Contacts".localStr)//todo i18n
            }else{
                self.friendTable.restore()
            }
        }
    }
    @IBOutlet weak var friendTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts".localStr
        refresh(sender: "" as AnyObject)
        friendTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        friendTable.tableFooterView = UIView(frame: .zero)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localStr)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.friendTable.addSubview(refreshControl)
    }

    @objc func refresh(sender:AnyObject) {

        CHAccountManager.shared.myFriends(){result in
            if case .success(let result) = result {
                L.d("🦁",result.isCache)
                L.d("🦁",result.data.first?.nickname)
                DispatchQueue.main.async {
                    self.mFriends = result.data.sorted { $0.nickname! < $1.nickname!}
                    self.friendTable.reloadData()
                }
            }
            if case .failure(let error) = result{
                L.d("🦁",error)
            }
            DispatchQueue.main.async {
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

        let check = UIAlertAction.addAction(title: "Add Member".localStr, style: .destructive) { (action) in
            DispatchQueue.main.async {
                ViewHelper.showLoadingInView(view: self.view)
            }

            self.sesame?.addKeyByFriend(accessLevel: .manager,uuidStr: self.mFriends[indexPath.row].id!.uuidString, { (result) in
                switch result {
                case .success(let _):
                    L.d("UI  ok!")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {

                        self.view.makeToast(error.localizedDescription)
                    }
                    L.d("UI!!!!!",error.localizedDescription)
                }
                DispatchQueue.main.async {
                    ViewHelper.hideLoadingView(view: self.view)
                }
            })
        }
        UIAlertController.showAlertController(tableView.cellForRow(at: indexPath)!,title: self.mFriends[indexPath.row].nickname,style: .actionSheet, actions: [check])

    }
}
extension AddFriendVC{
    @objc private func handleRightBarButtonTapped(_ sender: Any) {
        (self.tabBarController as! GeneralTabViewController).scanQR(from: "addSesame"){ (name) in
            DispatchQueue.main.async {
                ViewHelper.showLoadingInView(view: self.view)
            }
            self.sesame?.addKeyByFriend(accessLevel: .manager,uuidStr: name, { result in
                switch result {
                case .success(let message):
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    L.d("!!!!!",error.localizedDescription)
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
