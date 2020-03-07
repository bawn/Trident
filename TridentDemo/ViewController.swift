//
//  ViewController.swift
//  Trident_Example
//
//  Created by bawn on 2020/3/4.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailViewController = segue.destination as? DetailViewController
            , let cell = sender as? UITableViewCell
            , let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        detailViewController.indexPath = indexPath
    }
}
