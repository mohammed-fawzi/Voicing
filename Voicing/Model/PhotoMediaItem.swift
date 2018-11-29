//
//  PhotoMediaItem.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/28/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class PhotoMediaItem: JSQPhotoMediaItem {
    
    override func mediaViewDisplaySize() -> CGSize {
        let defaultSize: CGFloat = 200
        
        var thumbSize: CGSize = CGSize(width: defaultSize, height: defaultSize)
        
        if (self.image != nil && self.image.size.width != 0 && self.image.size.height != 0){
            
            let aspectRatio: CGFloat = self.image.size.width / self.image.size.height
            
            if self.image.size.width > self.image.size.height {
                thumbSize = CGSize(width: defaultSize, height: defaultSize/aspectRatio)
            } else {
                thumbSize = CGSize(width: defaultSize/aspectRatio, height: defaultSize)

            }
        }
        
        return thumbSize
    }
}
