//
//  CalculatorPresenter.swift
//  DCACalculator
//
//  Created by Ivan Pastukhov on 09.07.2021.
//

import UIKit

struct CalculatorPresenter {
    func getPresentation(result: DCAResult) -> CalculatorPresentation {
        let isProfitable = result.isProfitable == true
        let gainSymbol = isProfitable ? "+" : ""
        
        return .init(currentValueLabelBackgroundColor: isProfitable ? .systemGreen : .systemRed,
                     currentValue: result.currentValue.currencyFormat,
                     investmentAmount:result.investmentAmount.toCurrencyFormat(hasDecimalPlaces:false),
                     gain: result.gain.toCurrencyFormat(hasDollarSymbol: false, hasDecimalPlaces: false).prefix(with: gainSymbol),
                     yield: result.yield.percentageFormat.prefix(with: gainSymbol).addBrackets(),
                     yieldLabelTextColor: isProfitable ? .systemGreen : .systemRed,
                     annualReturn: result.annualReturn.percentageFormat,
                     annualReturnLabelTextColor: isProfitable ? .systemGreen : .systemRed)
    }
}

struct CalculatorPresentation {
    let currentValueLabelBackgroundColor: UIColor
    let currentValue: String
    let investmentAmount: String
    let gain: String
    let yield: String
    let yieldLabelTextColor: UIColor
    let annualReturn: String
    let annualReturnLabelTextColor: UIColor
}
