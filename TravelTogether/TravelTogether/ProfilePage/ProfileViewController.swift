//
//  ProfileViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userIntroduction: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var fanNumberLabel: UILabel!
    
    @IBOutlet weak var fanLabel: UILabel!
    
    @IBOutlet weak var followNumberLabel: UILabel!
    
    @IBOutlet weak var followLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var profileIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let headerView = ProfileHeaderView(reuseIdentifier: "ProfileHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 100)
        headerView.delegate = self
        tableView.tableHeaderView = headerView
    }


}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if profileIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell
            else { fatalError("Could not create ProfileCell") }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell
            else { fatalError("Could not create ProfileCell") }
            return cell
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if profileIndex == 0 {
           return 260
        } else {
            return 260
        }
    }
}

extension ProfileViewController: ProfileHeaderViewDelegate {
    func change(to index: Int) {
        profileIndex = index
        tableView.reloadData()
    }
}

