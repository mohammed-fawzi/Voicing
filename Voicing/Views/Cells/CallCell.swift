//
//  CallCell.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/27/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit

protocol CallCellDelegate {
    func didTappedAvatar(indexPath:IndexPath)
}

class CallCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var callType: UILabel!
    
    var indexPath:IndexPath!
    var delegate: CallCellDelegate?
    let tapGesture = UITapGestureRecognizer()


    override func awakeFromNib() {
        super.awakeFromNib()
        
        tapGesture.addTarget(self, action: #selector(self.avatarTapped))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func generateCellWith(user: FUser, indexPath: IndexPath){
        self.indexPath = indexPath
        
        fullNameLabel.text = user.fullname
        let avatar = imageFromData(pictureData: user.avatar).circleMasked
        avatarImageView.image = avatar
        //dateLabel.text = dateFormatter().
        
    }
    
    @objc func avatarTapped(){
        delegate!.didTappedAvatar(indexPath: indexPath)
    }

}
