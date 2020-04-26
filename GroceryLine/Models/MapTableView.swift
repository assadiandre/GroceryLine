//
//  MapTableView.swift
//  GroceryLine
//
//  Created by Andre Assadi on 4/25/20.
//  Copyright © 2020 AndreAssadiProjects. All rights reserved.
//

import Foundation
import UIKit


class MapTableViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {

    
    var data = [Int]()

  // variable that holds a stores a function
  // which return Void but accept an Int and a UITableViewCell as arguments.
    var didSelectRow: ((_ dataItem: Int, _ cell: UITableViewCell) -> Void)?

    init(data: [Int]) {
        self.data = data
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: "Table-Header", for: indexPath)
        
        if indexPath.row > 0, let locationCell = tableView.dequeueReusableCell(withIdentifier: "Table-Body", for: indexPath) as? LocationCell {
            locationCell.storeName.text = "Safeway, Berkeley CA"
            locationCell.storeImage.image = UIImage(named:"grocery")
            return locationCell
        } else {
            return defaultCell
        }
    }


    private func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRow(at: indexPath as IndexPath)!
        let dataItem = data[indexPath.row]

        if let didSelectRow = didSelectRow {
          // Calling didSelectRow that was set in ViewController.
            didSelectRow(dataItem, cell)
        }
    }
    
}
