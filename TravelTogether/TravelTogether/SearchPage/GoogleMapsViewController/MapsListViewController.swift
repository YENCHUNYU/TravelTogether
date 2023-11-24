//
//  MapsListViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/16.
//

import UIKit
import GoogleMaps
import CoreLocation

protocol MapListViewControllerDelegate: AnyObject {
    func didTapPlace(with coordinates: CLLocationCoordinate2D, indexPath: IndexPath)
}

class MapsListViewController: UIViewController {
    
    weak var delegate: MapListViewControllerDelegate?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(MapListCell.self, forCellReuseIdentifier: "MapListCell")
        return table
    }()
 
    private var places: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    public func update(with places: [Place]) {
        self.tableView.isHidden = false
        self.places = places
        tableView.reloadData()
    }
   
}
extension MapsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "MapListCell",
            for: indexPath)
            as? MapListCell else { fatalError("Could not create MapListCell")}
        cell.titleLabel.text = places[indexPath.row].name
        cell.addressLabel.text = places[indexPath.row].address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.isHidden = true
        
        let place = places[indexPath.row]
        GooglePlacesManager.shared.resolveLocation(for: place) { [weak self] result in
            switch result {
            case .success(let coordinate):
                DispatchQueue.main.async {
                    self?.delegate?.didTapPlace(with: coordinate, indexPath: indexPath)
                }
            case .failure(let error):
                print(error)
            }
            
        }
        }
}

extension MapsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}
