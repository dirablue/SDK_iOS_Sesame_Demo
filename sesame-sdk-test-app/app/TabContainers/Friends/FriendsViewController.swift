//
//  FriendsViewController.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/9.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK
public protocol FriendDelegate: class {
    func  refreshFriendPage()
}
extension FriendsViewController: SessionMoreMenuViewDelegate {
    @objc private func handleRightBarButtonTapped(_ sender: Any) {
        if self.menuFloatView?.superview != nil {
            hideMoreMenu()
        } else {
            showMoreMenu()
        }
    }

    func moreMenuView(_ menu: SessionMoreMenuView, didTap item: SessionMoreItem) {
        switch item.type {
        case .addFriends:
            (self.tabBarController as! GeneralTabViewController).scanQR()

        case .addDevices:
            (self.tabBarController as! GeneralTabViewController).goRegisterList()
        }
        hideMoreMenu(animated: false)
    }
}
extension FriendsViewController{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let rightButtonItem = UIBarButtonItem(image: UIImage.SVGImage(named: isDarkMode() ? "icons_outlined_addoutline_black":"icons_outlined_addoutline"), style: .done, target: self, action: #selector(handleRightBarButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightButtonItem
    }
}
class FriendsViewController: BaseViewController {
    private var menuFloatView: SessionMoreFrameFloatView?
    private func showMoreMenu() {
        if menuFloatView == nil {
            let y = Constants.statusBarHeight + 44
            let frame = CGRect(x: 0, y: y, width: view.bounds.width, height: view.bounds.height - y)
            menuFloatView = SessionMoreFrameFloatView(frame: frame)
            menuFloatView?.delegate = self
        }
        menuFloatView?.show(in: self.view)
    }

    private func hideMoreMenu(animated: Bool = true) {
        menuFloatView?.hide(animated: animated)
    }


    @IBOutlet weak var friendsTables: UITableView!
    var refreshControl:UIRefreshControl = UIRefreshControl()
    var mFriends = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()


        (self.tabBarController as! GeneralTabViewController).delegateFriend = self


        CHAccountManager.shared.myFriends(){ friends in
            DispatchQueue.main.async {
                self.mFriends = friends
                self.friendsTables.reloadData()
            }
        }
        friendsTables.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        friendsTables.tableFooterView = UIView(frame: .zero)

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.friendsTables.addSubview(refreshControl)

    }

    @objc func refresh(sender:AnyObject) {
        CHAccountManager.shared.myFriends(){ friends in
            DispatchQueue.main.async {
                self.mFriends = friends
                self.friendsTables.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
}//end FriendsViewController class
extension FriendsViewController: UITableViewDataSource {

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
extension FriendsViewController: UITableViewDelegate {


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        L.d(indexPath.section,indexPath.row)
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "unfriend"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            L.d(self.mFriends[indexPath.row].id)
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
extension FriendsViewController:FriendDelegate{
    func refreshFriendPage() {
        self.refreshControl.beginRefreshing()
        CHAccountManager.shared.myFriends(){ friends in
            DispatchQueue.main.async {
                self.mFriends = friends
                self.friendsTables.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
}
