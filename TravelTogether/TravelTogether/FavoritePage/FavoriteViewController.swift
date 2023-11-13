//
//  FavoriteViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/13.
//

import UIKit

class FavoriteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }


}

extension FavoriteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchMemoriesCell", for: indexPath) as? SearchMemoriesCell
        else { fatalError("Could not create SearchMemoriesCell") }
        return cell
    }
    
    
    
    
}

extension FavoriteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        330
    }
}
