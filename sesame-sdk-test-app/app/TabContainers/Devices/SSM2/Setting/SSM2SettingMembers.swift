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
            self.performSegue(withIdentifier:  "addfriend", sender: nil)
        }
        if(indexPath.row == self.memberList.count + 1){
            self.performSegue(withIdentifier:  "deletefriend", sender: nil)
        }
    }
}
extension SSM2SettingVC:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifer", for: indexPath) as! UserCell
        
        if(indexPath.row == self.memberList.count ){
            cell.avatar.image = UIImage.SVGImage(named:"icon_add")
            cell.ownerKing.isHidden = true
            
            return cell
        }
        else if(indexPath.row == (self.memberList.count + 1)){//todo bad name
            cell.avatar.image = UIImage.SVGImage(named:"icon_delete")
            cell.ownerKing.isHidden = true
            
            return cell
        }else{
            let client = self.memberList[indexPath.row]
            cell.avatar.image = UIImage.makeLetterAvatar(withUsername: client.firstname)
            
            if(client.roleType ==  CHDeviceAccessLevel.owner.rawValue){
                cell.ownerKing.image = UIImage.SVGImage(named:"owner_king")
                cell.ownerKing.isHidden = false
            }else{
                cell.ownerKing.image = UIImage.SVGImage(named:"owner_king")
                cell.ownerKing.isHidden = true
            }
            
        }
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memberList.count + 2
    }
    
}


class UserCell: UICollectionViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var ownerKing: UIImageView!
    
}
