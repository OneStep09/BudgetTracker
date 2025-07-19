//
//  DateStringConverter.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 10.06.2025.
//

import Foundation


enum DateFormatType: String {
    case iso8601 = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case yearMonthDate = "yyy-MM-dd"
    case time = "HH:mm"
}

class DateStringConverter {
    
    static let dateFormatter = DateFormatter()
    
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    
    
    public static func date(from string: String) -> Date? {
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        dateFormatter.locale = Locale.current
//        dateFormatter.timeZone = TimeZone.current
//        return dateFormatter.date(from: string)
        
        return iso8601.date(from: string)
    }
    

    
    public static func string(from date: Date) -> String {
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

