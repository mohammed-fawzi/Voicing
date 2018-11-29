//
//  CallsViewController.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/27/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit

class CallsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }


}


//- MARK: TableView data Source
extension CallsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.callCell.rawValue, for: indexPath) as! CallCell
        
        return cell
    }
    
    
}


//- MARK: Tabel View Delegate
extension CallsViewController: UITableViewDelegate {

    
}


//- MARK: helper methedos
extension CallsViewController {
    
    
}
