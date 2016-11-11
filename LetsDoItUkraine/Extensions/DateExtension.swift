//
//  DateExtension.swift
//  LetsDoItUkraine
//
//  Created by Anton A on 23.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

extension DateFormatter {
    convenience init(dateStyle: DateFormatter.Style) {
        self.init()
        self.dateStyle = dateStyle
    }
}

extension Date {
    struct Formatter {
        static let shortDate = DateFormatter(dateStyle: .short)
    }
    var shortDate: String {
        return Formatter.shortDate.string(from: self)
    }
    var dateWithLocale: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale!
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }
}
