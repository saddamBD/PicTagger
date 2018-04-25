//
//  TagTableVC.swift
//  PicTaggerImagga
//
//  Created by General on 4/25/18.
//  Copyright © 2018 General. All rights reserved.
//



import UIKit

class TagTableVC: UITableViewController {
    
    var TagItem: [TagData] = []
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TagItem.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = TagItem[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = cellData.label
        return cell
    }
}




