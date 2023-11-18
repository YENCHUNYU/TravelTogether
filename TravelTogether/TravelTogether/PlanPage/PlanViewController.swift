//
//  PlanViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit

class PlanViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! 
    
    var planIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let headerView = PlanHeaderView(reuseIdentifier: "PlanHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 100)
        headerView.delegate = self
        tableView.tableHeaderView = headerView
    }
}

extension PlanViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if planIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCell", for: indexPath) as? MyPlanCell
            else { fatalError("Could not create PlanCell") }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TogetherPlanCell", for: indexPath) as? TogetherPlanCell
            else { fatalError("Could not create TogetherPlanCell") }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToEdit", sender: self)
    }
}

extension PlanViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if planIndex == 0 {
           return 280
        } else {
            return 280
        }
    }
}

extension PlanViewController: PlanHeaderViewDelegate {
    func change(to index: Int) {
        planIndex = index
        tableView.reloadData()
    }
}

