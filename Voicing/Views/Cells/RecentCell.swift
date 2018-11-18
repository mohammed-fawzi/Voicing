//
//  RecentCell.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/18/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit

protocol RecentCellDelegate {
    func didTappedAvatar(indexPath: IndexPath)
}

class RecentCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var counterBackgroundView: UIView!
    @IBOutlet weak var counterLabel: UILabel!
    
    var delegate:RecentCellDelegate?
    var indexPath: IndexPath!
    let tapGesture = UITapGestureRecognizer()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        counterBackgroundView.layer.cornerRadius = counterBackgroundView.frame.width / 2
        tapGesture.addTarget(self, action: #selector(self.avatarTapped))
        avatarImageView.addGestureRecognizer(tapGesture)
        avatarImageView.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func generateCell(recentChat: NSDictionary, indexPath: IndexPath){
        self.indexPath = indexPath
        
        fullNameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        lastMessageLabel.text = recentChat[kLASTMESSAGE] as? String
        
        if let avatarString = recentChat[kAVATAR]  {
            let image = imageFromData(pictureData: avatarString as! String)
            avatarImageView.image = image.circleMasked
        }
        
        if recentChat[kCOUNTER] as! Int != 0 {
            counterBackgroundView.isHidden = false
            counterLabel.isHidden = false
            counterLabel.text = "\(recentChat[kCOUNTER] as! Int)"
        } else {
            counterBackgroundView.isHidden = true
            counterLabel.isHidden = true
        }
        
        var date: Date!
        if let createdAt = recentChat[kDATE] {
            if (createdAt as! String).count != 14 {
                date = Date()
            } else{
                date = dateFormatter().date(from: createdAt as! String)!
            }
        } else {
            date = Date()
        }
        
        dateLabel.text = timeElapsed(date: date)
        
        
    }
    
    @objc func avatarTapped(){
        delegate?.didTappedAvatar(indexPath: indexPath)
    }

}
