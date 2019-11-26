//
//  SSM2RoomUsers.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/17.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK
//extension SSM2RoomMainVC:UICollectionViewDelegate{
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
//    {
//        self.performSegue(withIdentifier:  "users", sender: self.userList)
//    }
//}
//extension SSM2RoomMainVC:UICollectionViewDataSource{
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifer", for: indexPath) as! UserCell
//        let client = self.userList[indexPath.row]
//        cell.avatar.image = UIImage.makeLetterAvatar(withUsername: client.nickname)
//        return cell
//        
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.userList.count
//    }
//    
//}
class UserCell: UICollectionViewCell {
    @IBOutlet weak var avatar: UIImageView!
}
