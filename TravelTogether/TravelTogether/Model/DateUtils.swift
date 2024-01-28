//
//  DateUtils.swift
//  TravelTogether
//
//  Created by User on 2024/1/23.
//

import UIKit
import FirebaseFirestore

class DateUtils {
    static func changeDateFormat(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = dateFormatter.date(from: date) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy年MM月dd日"
            let formattedString = outputFormatter.string(from: date)
            return formattedString
        } else {
            print("Failed to convert the date string.")
            return ""
        }
    }
    
    static func convertTimestampToDate(original dbData: [String: Any]) -> [String: Any] {
        var updatedData = dbData
    
        if let startDateTimestamp = dbData["startDate"] as? Timestamp {
            updatedData["startDate"] = startDateTimestamp.dateValue().timeIntervalSinceReferenceDate
        }
        if let endDateTimestamp = dbData["endDate"] as? Timestamp {
            updatedData["endDate"] = endDateTimestamp.dateValue().timeIntervalSinceReferenceDate
        }
            return updatedData
        }
}
