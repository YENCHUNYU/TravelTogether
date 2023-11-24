//
//  FavoriteViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/13.
//

import UIKit

class FavoriteViewController: UIViewController {

    var favoriteIndex = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchHeaderView.self, forHeaderFooterViewReuseIdentifier: "SearchHeaderView")
        let headerView = SearchHeaderView(reuseIdentifier: "SearchHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 100)
        tableView.tableHeaderView = headerView
        headerView.delegate = self
    }
}

extension FavoriteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if favoriteIndex == 0 || favoriteIndex == 1 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "SearchMemoriesCell",
                for: indexPath) as? SearchMemoriesCell
            else { fatalError("Could not create SearchMemoriesCell") }
            if let image = UIImage(named: "台北景點") {
                cell.memoryImageView.image = image
            }
            cell.userNameLabel.text = "Jenny"
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SpotCell", for: indexPath) as? SpotCell
            else { fatalError("Could not create SpotCell") }
            return cell
        }
    }
}

extension FavoriteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if favoriteIndex == 0 || favoriteIndex == 1 {
           return 330
        } else {
            return 280
        }
    }
}

extension FavoriteViewController: SearchHeaderViewDelegate {
    func change(to index: Int) {
        favoriteIndex = index
        tableView.reloadData()
    }
}
