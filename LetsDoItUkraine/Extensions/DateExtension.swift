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
}
