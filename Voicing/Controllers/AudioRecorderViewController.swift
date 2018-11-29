//
//  AudioRecorderViewController.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/28/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import Foundation
import IQAudioRecorderController

class AudioRecorderViewController {
    
    var delegate: IQAudioRecorderViewControllerDelegate
    
    init(delegate: IQAudioRecorderViewControllerDelegate) {
        self.delegate = delegate
    }
    
    
    func presentAudioRcorderViewController(tareget: UIViewController){
        
        let controller = IQAudioRecorderViewController()
        controller.delegate = delegate
        controller.title = "Record"
        controller.maximumRecordDuration = kAUDIOMAXDURATION
        controller.allowCropping = true
        
        tareget.presentBlurredAudioRecorderViewControllerAnimated(controller)
    }
}
