//
//  Double+Extensions.swift
//  ShopSmart Uni
//
//  Created by Вячеслав on 9/6/25.
//

import Foundation

extension Double {
    func formatted(decimalPlaces: Int) -> String {
        return String(format: "%.\(decimalPlaces)f", self)
    }
    
    var currency: String {
        return "$\(formatted(decimalPlaces: 2))"
    }
    
    var currencyWhole: String {
        return "$\(formatted(decimalPlaces: 0))"
    }
    
    var percentage: String {
        return "\(formatted(decimalPlaces: 0))%"
    }
    
    var percentageDecimal: String {
        return "\(formatted(decimalPlaces: 1))%"
    }
}
