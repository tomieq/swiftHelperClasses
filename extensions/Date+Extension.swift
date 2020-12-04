//
//  Date+Extension.swift
//
//  Created by tomieq on 04.10.2017.
//  Copyright © 2017 tomieq. All rights reserved.
//

import Foundation

extension Date {
    func isBetweeen(date date1: Date, andDate date2: Date) -> Bool {
        let earlierDate = date1 < date2 ? date1 : date2
        let laterDate = date1 > date2 ? date1 : date2
        return earlierDate < self && laterDate > self
    }
}

extension Date {
    
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
    
    func formatTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
    
    
    func formatDateWithTime() -> String {
        return "\(self.formatDate()) \(self.formatTime())"
    }
}
