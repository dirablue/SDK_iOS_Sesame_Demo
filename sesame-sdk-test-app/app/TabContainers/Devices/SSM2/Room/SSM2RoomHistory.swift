//
//  SSM2RoomHistory.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/17.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK

extension SSM2RoomMainVC: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 60
//    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = groupHistory[section].first?.timestamp?.toYMD()
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryHeader") as! HistoryHeader
        cell.userLB.text = title
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return  groupHistory.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupHistory[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell

        let history = groupHistory[indexPath.section][indexPath.row]

        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss a"
        f.locale = Locale(identifier: "ja_JP")
        f.amSymbol = "AM"
        f.pmSymbol = "PM"
        let now = history.timestamp
        let title = history.operater?.name ?? history.event!.localStr

        cell.timeLb.text = "\(f.string(from: now!))"
        cell.userLB.text = title

        if let opname = history.operater?.name{
            cell.avatarImg.image = UIImage.makeLetterAvatar(withUsername: history.operater?.firstname)
        }else{
            cell.avatarImg.image = UIImage.SVGImage(named: history.eventType == .autolock ? "autolock":"handmove")
        }

        cell.eventImg.image = UIImage.SVGImage(named: CHHistoryEventType.isLockType(history.eventType) ? "icon_lock":"icon_unlock")




        return cell
    }
}
