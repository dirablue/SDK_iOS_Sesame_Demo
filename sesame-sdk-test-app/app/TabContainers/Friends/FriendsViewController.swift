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
            (self.tabBarController as! GeneralTabViewController).scanQR(){ name in
                self.refreshFriendPage()
                L.d("測試回傳")
            }
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
    var mFriends = [CHFriend](){
        didSet {
            L.d("變動")
            if(self.mFriends.count == 0) {                          self.friendsTables.setEmptyMessage("No Friends".localStr)//todo i18n
            }else{
                self.friendsTables.restore()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        CHAccountManager.shared.nowFriends(){ friends in
            DispatchQueue.main.async {
                self.mFriends = friends.sorted { $0.nickname! < $1.nickname!}
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        L.d("好友列表頁面!!")
        (self.tabBarController as! GeneralTabViewController).delegateFriend = self
        
        refreshFriendPage()
        
        friendsTables.tableFooterView = UIView(frame: .zero)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localStr)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.friendsTables.addSubview(refreshControl)
        
    }
    
    @objc func refresh(sender:AnyObject) {
        refreshFriendPage()
    }
}//end FriendsViewController class
extension FriendsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mFriends.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FRCell", for: indexPath) as! FriendCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.nameLb.text = "\(self.mFriends[indexPath.row].nickname ?? "-")"
        cell.headImg.image = UIImage.makeLetterAvatar(withUsername: "\(self.mFriends[indexPath.row].givenname ?? "-")")
        return cell
    }
}
extension FriendsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alertController = UIAlertController(title: self.mFriends[indexPath.row].nickname, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel".localStr, style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "DeleteFriend".localStr, style: .destructive){
            UIAlertAction in
            //            L.d("self.mFriends",self.mFriends.count)
            //            L.d("indexPath.row",indexPath.row)
            //            L.d("indexPath.row",self.mFriends[indexPath.row])
            //            L.d("self.mFriends[indexPath.row].id!",self.mFriends[indexPath.row].id!)
            
            CHAccountManager.shared.unfriend(fdId: self.mFriends[indexPath.row].id!.uuidString){ isSuccess in
                DispatchQueue.main.async {
                    if(isSuccess){
                        self.mFriends.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)

                    }
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
extension FriendsViewController:FriendDelegate{
    func refreshFriendPage() {
        DispatchQueue.main.async {
            self.refreshControl.beginRefreshing()
            self.mFriends.removeAll()
            self.friendsTables.reloadData()
        }
        CHAccountManager.shared.myFriends(){ friends in
            DispatchQueue.main.async {
                self.mFriends = friends.sorted { $0.nickname! < $1.nickname!}
                self.friendsTables.reloadData()
                self.refreshControl.endRefreshing()

            }
        }
    }
}
