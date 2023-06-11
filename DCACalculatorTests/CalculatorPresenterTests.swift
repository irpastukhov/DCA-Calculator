//
//  CalculatorPresenterTests.swift
//  DCAServiceTests
//
//  Created by Ivan Pastukhov on 28.07.2021.
//

import XCTest
@testable import DCACalculator

final class CalculatorPresenterTests: XCTestCase {

    var sut: CalculatorPresenter!
    
    override func setUpWithError() throws {
        sut = CalculatorPresenter()
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testLabelsTextColor_givenResultIsProfitable_expectSystemGreen() {
        let result = DCAResult(currentValue: 0,
                               investmentAmount: 0,
                               gain: 0,
                               yield: 0,
                               annualReturn: 0,
                               isProfitable: true)
        let presentation = sut.getPresentation(result: result)
        XCTAssertEqual(presentation.annualReturnLabelTextColor, UIColor.systemGreen)
        XCTAssertEqual(presentation.yieldLabelTextColor, UIColor.systemGreen)
    }
    
    func testLabelsTextColor_givenResultIsNotProfitable_expectSystemRed() {
        let result = DCAResult(currentValue: 0,
                               investmentAmount: 0,
                               gain: 0,
                               yield: 0,
                               annualReturn: 0,
                               isProfitable: false)
        let presentation = sut.getPresentation(result: result)
        XCTAssertEqual(presentation.annualReturnLabelTextColor, UIColor.systemRed)
        XCTAssertEqual(presentation.yieldLabelTextColor, UIColor.systemRed)
    }
    
    func testYieldLabel_expectBrackets() {
        let openBracket: Character = "("
        let closeBracket: Character = ")"
        let result = DCAResult(currentValue: 0,
                               investmentAmount: 0,
                               gain: 0, yield: 0.25,
                               annualReturn: 0,
                               isProfitable: false)
        let presentation = sut.getPresentation(result: result)
        XCTAssertEqual(presentation.yield.first, openBracket)
        XCTAssertEqual(presentation.yield.last, closeBracket)
    }

}
