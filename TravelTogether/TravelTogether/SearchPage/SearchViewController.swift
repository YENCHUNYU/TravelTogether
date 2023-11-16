//
//  SearchViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/13.
//

import UIKit
import GoogleMaps

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var button: UIButton!
    
    var searchIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchHeaderView.self, forHeaderFooterViewReuseIdentifier: "SearchHeaderView")
        let headerView = SearchHeaderView(reuseIdentifier: "SearchHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 100)
        headerView.delegate = self
        tableView.tableHeaderView = headerView
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToMap", sender: sender)
    }
    
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchIndex == 0 || searchIndex == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchMemoriesCell", for: indexPath) as? SearchMemoriesCell
            else { fatalError("Could not create SearchMemoriesCell") }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath) as? MapViewCell
            else { fatalError("Could not create MapViewCell") }
            return cell
        }   
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchIndex == 0 {
            performSegue(withIdentifier: "MemoryDetail", sender: self)
        }
        
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchIndex == 0 || searchIndex == 1 {
           return 330
        } else {
            return 572 
        }
    }
}

extension SearchViewController: SearchHeaderViewDelegate {
    func change(to index: Int) {
        searchIndex = index
        tableView.reloadData()
    }
}

