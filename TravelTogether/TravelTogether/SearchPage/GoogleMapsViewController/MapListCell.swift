//
//  MapViewCell.swift
//  TravelTogether
//
//  Created by User on 2023/11/16.
//

import UIKit
import GoogleMaps

class MapListCell: UITableViewCell {
    
    var titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 18, weight: .light)
        title.heightAnchor.constraint(equalToConstant: 26).isActive = true
        return title
    }()
    
    var addressLabel: UILabel = {
        let address = UILabel()
        address.translatesAutoresizingMaskIntoConstraints = false
        address.textAlignment = .left
        address.font = UIFont.systemFont(ofSize: 14, weight: .light)
        address.textColor = .gray
        address.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return address
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(addressLabel)
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        
        addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        addressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
