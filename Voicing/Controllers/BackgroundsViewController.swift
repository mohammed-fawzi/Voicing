//
//  BackgroundsViewController.swift
//  Voicing
//
//  Created by mohamed fawzy on 12/11/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit
import ProgressHUD

private let reuseIdentifier = "Cell"

class BackgroundsViewController: UICollectionViewController {
    
    var backgrounds: [UIImage] = []
    var userDefaults = UserDefaults.standard
    
    let imageNames: [String] = ["bg0","bg1","bg2","bg3","bg4","bg5","bg6","bg7","bg8","bg9","bg10","bg11"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateImagesFromNames()
        
        let resetBarButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(self.resetButtonTapped))
        
        navigationItem.rightBarButtonItem = resetBarButton
      
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }

    
    // MARK: UICollectionViewDataSource

  

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return backgrounds.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.backgroundCell.rawValue, for: indexPath) as! BackgroundCell
        
        cell.generateCell(image: backgrounds[indexPath.row])
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

  
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        userDefaults.set(imageNames[indexPath.row], forKey: kBACKGROUBNDIMAGE)
        userDefaults.synchronize()
        ProgressHUD.showSuccess("Set")
    }
   

  
 // MARK: helpers
    
    func generateImagesFromNames(){
        
        for name in imageNames {
            if let image = UIImage(named: name){
                backgrounds.append(image)

            }
        }
    }
  

    @objc func resetButtonTapped(){
        userDefaults.removeObject(forKey: kBACKGROUBNDIMAGE)
        userDefaults.synchronize()
        ProgressHUD.showSuccess("Reset Done")
    }
}
