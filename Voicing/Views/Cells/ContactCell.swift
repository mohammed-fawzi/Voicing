//
//  ContactCell.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/15/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit

protocol ContactCellDelegate {
    func didTappedAvatar(indexPath:IndexPath)
}

class ContactCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var indexPath:IndexPath!
    var delegate: ContactCellDelegate?
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
        
        nameLabel.text = user.fullname
        let avatar = imageFromData(pictureData: user.avatar).circleMasked
        avatarImageView.image = avatar
        
    }
    
    @objc func avatarTapped(){
        delegate!.didTappedAvatar(indexPath: indexPath)
    }

}
