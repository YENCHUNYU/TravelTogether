//
//  MemoryViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit

class MemoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var memoryIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let headerView = MemoryHeaderView(reuseIdentifier: "MemoryHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 100)
        headerView.delegate = self
        tableView.tableHeaderView = headerView
    }
}

extension MemoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if memoryIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryCell", for: indexPath) as? MemoryCell
            else { fatalError("Could not create MemoryCell") }
            if let image = UIImage(named: "台北景點") {
                cell.memoryImageView.image = image
            }
            cell.memoryNameLabel.text = "台北一日遊"
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryCell", for: indexPath) as? MemoryCell
            else { fatalError("Could not create MemoryCell") }
            return cell
        }
    }
}

extension MemoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if memoryIndex == 0 {
           return 280
        } else {
            return 280
        }
    }
}

extension MemoryViewController: MemoryHeaderViewDelegate {
    func change(to index: Int) {
        memoryIndex = index
        tableView.reloadData()
    }
}
