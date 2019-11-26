//
//  SSM2SettingMembers.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/11/12.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK
extension SSM2SettingVC:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if(indexPath.row == self.memberList.count){
            L.d("\(indexPath.section)\(indexPath.row)")
            self.performSegue(withIdentifier:  "addfriend", sender: nil)
        }
        if(indexPath.row == self.memberList.count + 1){
            L.d("\(indexPath.section)\(indexPath.row)")
            self.performSegue(withIdentifier:  "deletefriend", sender: nil)
        }    }
}
extension SSM2SettingVC:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifer", for: indexPath) as! UserCell

        if(indexPath.row == self.memberList.count ){
//                   cell.avatar.image = UIImage.makeLetterAvatar(withUsername: "＋")
            cell.avatar.image = UIImage(named: "img-add-guest")
                   return cell
               }
               else if(indexPath.row == (self.memberList.count + 1)){//todo bad name
//                   cell.avatar.image = UIImage.makeLetterAvatar(withUsername: "-")
            cell.avatar.image = UIImage(named: "img-delete-guest")
                   return cell
               }else{
                   let client = self.memberList[indexPath.row]
                   cell.avatar.image = UIImage.makeLetterAvatar(withUsername: client.nickname)
               }
               return cell

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memberList.count + 2
    }

}