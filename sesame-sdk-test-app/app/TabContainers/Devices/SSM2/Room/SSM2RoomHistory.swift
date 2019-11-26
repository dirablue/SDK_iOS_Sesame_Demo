//
//  SSM2RoomHistory.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/17.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK

extension SSM2RoomMainVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mHistoryList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        let history = mHistoryList[indexPath.row]


        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss a"
        f.locale = Locale(identifier: "ja_JP")
        f.amSymbol = "AM"
        f.pmSymbol = "PM"
        let now = history.timestamp
        let whodid = history.operateBy?.nickname ?? history.eventStr?.localStr//todo crash 1

        cell.timeLb.text = "\(f.string(from: now!))"
        cell.userLB.text = whodid

        if(history.event == .lock  || history.event == .autolock || history.event == .manualLock ){
            cell.eventImg.image = UIImage(named: "img-lock")
        }else{
            cell.eventImg.image = UIImage(named: "img-unlock")
        }

        return cell
    }
}
