//
//  addToPlanListViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/17.
//

import UIKit

class AddToPlanListViewController: UIViewController {

    var plans: [String] = ["台中一日遊"]

    @IBOutlet weak var tableView: UITableView!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(AddToListFooterView.self, forHeaderFooterViewReuseIdentifier: "AddToListFooterView")
        }
    }

extension AddToPlanListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddToListCell", for: indexPath) as? AddToListCell
            else { fatalError("Could not create AddToListCell") }
        cell.planTitleLabel.text = plans[indexPath.row]
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            performSegue(withIdentifier: "MemoryDetail", sender: self)
  
    }
// FOOTER
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddToListFooterView") as? AddToListFooterView
        else { fatalError("Could not create AddToListFooterView") }
        view.createNewPlanButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return view
    }
    
    @objc func createButtonTapped() {
//    performSegue(withIdentifier: "goToCreate", sender: self)
        //
        guard let createPlanViewController = storyboard?.instantiateViewController(withIdentifier: "CreatePlanViewController") as? CreatePlanViewController
        else {fatalError("Can not instantiate CreatePlanViewController")}

                // Set the closure to receive the planName value
                createPlanViewController.onSave = { [weak self] planName in
                    // Use the planName value as needed
                    self?.handlePlanName(planName)
                }

                navigationController?.pushViewController(createPlanViewController, animated: true)
        }
    
    func handlePlanName(_ planName: String) {
        plans.append(planName)
        tableView.reloadData()
        }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        40
    }
}

extension AddToPlanListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     
           return 60
       
    }
}

class AddToListCell: UITableViewCell {
    
    @IBOutlet weak var planTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}
   
class AddToListFooterView: UITableViewHeaderFooterView {
    
    let createNewPlanButton: UIButton = {
        let create = UIButton()
        create.translatesAutoresizingMaskIntoConstraints = false
        create.setTitle("建立新行程", for: .normal)
        create.backgroundColor = .lightGray
//        create.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return create
    }()
    
//    @objc func createButtonTapped() {
//
//    }
    
    override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            commonInit()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
    
    func commonInit() {
        contentView.addSubview(createNewPlanButton)
        createNewPlanButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0).isActive = true
        createNewPlanButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
    }
    
}
