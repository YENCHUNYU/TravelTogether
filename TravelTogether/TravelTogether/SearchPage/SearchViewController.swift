//
//  SearchViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/13.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchHeaderView.self, forHeaderFooterViewReuseIdentifier: "SearchHeaderView")
        let headerView = SearchHeaderView(reuseIdentifier: "SearchHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 50)
            tableView.tableHeaderView = headerView
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchMemoriesCell", for: indexPath) as? SearchMemoriesCell
        else { fatalError("Could not create SearchMemoriesCell") }
        return cell
    }
//-----HEADER
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//       guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SearchHeaderView") as? SearchHeaderView
//        else { fatalError("Could not create SearchHeaderView") }
//        return headerView
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        50
//    }
//
    
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        330
    }
    
}
