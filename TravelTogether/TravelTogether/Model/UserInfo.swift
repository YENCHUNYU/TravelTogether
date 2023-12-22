//
//  UserInfo.swift
//  TravelTogether
//
//  Created by User on 2023/11/30.
//

import Foundation

struct UserInfo {
    var email: String
    var name: String
    var id: String
    var photo: String?
    var ref: [Any]?
    
    func toDictionary() -> [String: Any] {
        return [
            "email": email,
            "name": name,
            "id": id,
            "photo": photo ?? "",
            "ref": ref ?? []
        ]
    }
}
