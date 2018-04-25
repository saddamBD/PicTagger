//
//  TagVC.swift
//  PicTaggerImagga
//
//  Created by General on 4/25/18.
//  Copyright © 2018 General. All rights reserved.
//


import UIKit

class TagVC: UIViewController {
    
    var tags: [String]?
    var tableViewController: TagTableVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        DataManipulate()
    }
    
    
    
    func DataManipulate() {
        if let tags = tags {
            tableViewController?.TagItem = tags.map {
                TagData(label: $0)
            }
        } else {
            tableViewController?.TagItem = [TagData(label: "Tags are not founds")]
        }
        
        
        tableViewController?.tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Data" {
            tableViewController = segue.destination as? TagTableVC
        }
    }
    
    
}

