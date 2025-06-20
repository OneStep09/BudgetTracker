//
//  DateStringConverter.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 10.06.2025.
//

import Foundation


enum DateFormatType: String {
    case iso8601 = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case time = "HH:mm"
}

class DateStringConverter {
    
    static let dateFormatter = DateFormatter()
    
    public static func getDate(from string: String) -> Date? {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        dateFormatter.locale = Locale.current
//        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date(from: string)
    }
    

    
    public static func getStringUTC(from date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: date)
    }
    
    
    public static func getString(from date: Date, formatType: DateFormatType = .iso8601) -> String {
        dateFormatter.dateFormat = formatType.rawValue
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: date)
    }
    
    
    
    
    
}

