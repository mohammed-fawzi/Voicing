//
//  BackgroundCell.swift
//  Voicing
//
//  Created by mohamed fawzy on 12/11/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit

class BackgroundCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(image: UIImage){
        
        self.imageView.image = image
    }
}
