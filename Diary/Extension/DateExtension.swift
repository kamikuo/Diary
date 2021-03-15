//
//  DateExtension.swift
//  Diary
//
//  Created by kamikuo on 2020/10/01.
//

import Foundation

//MARK:- ISO
public extension Date {
    private static let ISOformatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
    var ISOString: String {
        return Date.ISOformatter.string(from: self)
    }
    
    init?(ISOString: String) {
        if let date = Date.ISOformatter.date(from: ISOString) {
            self = date
        } else {
            return nil
        }
    }
}

public extension Date {
    var firstDayInMonth: Date {
        let month = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: DateComponents(year: month.year!, month: month.month!, day: 1))!
    }
    
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
}

//MARK:- Format
public extension Date {
    private static let enFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.system
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    init?(string: String, format: String) {
        Date.enFormatter.dateFormat = format
        if let date = Date.enFormatter.date(from: string) {
            self = date
        } else {
            return nil
        }
    }
    
    private static let localeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.system
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()
    
    func formattedDate(format: String) -> String{
        Date.localeFormatter.dateFormat = format
        return Date.localeFormatter.string(from: self)
    }
    
    func formattedDate(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        Date.localeFormatter.dateFormat = nil
        Date.localeFormatter.dateStyle = dateStyle
        Date.localeFormatter.timeStyle = timeStyle
        return Date.localeFormatter.string(from: self)
    }
    
    func formattedDate(localizedTemplate: String) -> String{
        Date.localeFormatter.setLocalizedDateFormatFromTemplate(localizedTemplate)
        return Date.localeFormatter.string(from: self)
    }

    func formattedDate(style: DateFormatter.Style, year: Bool = false, month: Bool = false, day: Bool = false, hour: Bool = false, minute: Bool = false, second: Bool = false) -> String {
        let long = style == .long || style == .full
        let short = style == .short
        var template = ""
        if year { template += long ? "yyyy" : "yy" }
        if month { template += long ? "MMMM" : (short ? "MM" : "MMM") }
        if day { template += long ? "dd" : "d" }
        if hour { template += long ? "HH" : "H" }
        if minute { template += long ? "mm" : "m" }
        if second { template += long ? "ss" : "s" }
        return self.formattedDate(localizedTemplate: template)
    }
}
