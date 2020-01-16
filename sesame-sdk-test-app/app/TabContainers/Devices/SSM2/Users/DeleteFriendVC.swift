//
//  DeleteFriendVC.swift
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
    var memberList = [Operater]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Members".localStr // todo i18n
        friendTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        friendTable.tableFooterView = UIView(frame: .zero)
    }
}
extension DeleteFriendVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FRCell", for: indexPath) as! FriendCell
        cell.nameLb.text = "\(self.memberList[indexPath.row].name ?? "?")"
        cell.headImg.image = UIImage.makeLetterAvatar(withUsername: "\(self.memberList[indexPath.row].firstname ?? "?")")

        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        return cell
    }
}
extension DeleteFriendVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        L.d(indexPath.section,indexPath.row)

        let alertController = UIAlertController(title: self.memberList[indexPath.row].name, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel".localStr, style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete Member".localStr, style: .destructive){
            UIAlertAction in

            DispatchQueue.main.async {
                ViewHelper.showLoadingInView(view: self.view)
            }
            let member = self.memberList[indexPath.row]

            self.sesame!.revokeKey(member) { (result) in
                DispatchQueue.main.async {
                    ViewHelper.hideLoadingView(view: self.view)
                }
                if result.success {
                    if(member.id == CHAccountManager.shared.candyhouseUserId){
                        DispatchQueue.main.async {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        ViewHelper.showLoadingInView(view: self.view)
                    }
                    self.sesame?.getDeviceMembers(){result ,users in
                        DispatchQueue.main.async {
                            self.memberList =  users
                            self.friendTable.reloadData()
                            ViewHelper.hideLoadingView(view: self.view)
                        }
                    }

                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
    }


}
