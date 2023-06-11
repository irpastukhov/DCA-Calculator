//
//  TimeSeriesMonthlyAdjusted.swift
//  dca-calculator
//
//  Created by Ivan Pastukhov on 17.07.2021.
//

import Foundation

struct MonthInfo {
    let date: Date
    let adjustedOpen: Double
    let adjustedClose: Double
}

struct TimeSeriesMonthlyAdjusted: Decodable {
    let meta: Meta
    let timeSeries: [String: OpenHighLowClose]
    
    enum CodingKeys: String, CodingKey {
        case meta = "Meta Data"
        case timeSeries = "Monthly Adjusted Time Series"
    }
    
    func getMonthInfos() -> [MonthInfo] {
        var monthInfos: [MonthInfo] = []
        let sortedTimeSeries = timeSeries.sorted (by: { $0.key > $1.key })
        
        for (dateString, ohlc) in sortedTimeSeries {
            let dateFormatter = DateFormatter ( )
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let date = dateFormatter.date(from: dateString),
                  let adjustedOpen = getAdjustedOpen(from: ohlc),
                  let adjustedClose = ohlc.adjustedClose.toDouble()
            else { return [] }
            let monthInfo = MonthInfo(date: date,
                                      adjustedOpen: adjustedOpen,
                                      adjustedClose: adjustedClose)
            monthInfos.append(monthInfo)
        }
        return monthInfos
    }
    
    private func getAdjustedOpen(from ohlc: OpenHighLowClose) -> Double? {
        guard let open = ohlc.open.toDouble(),
                let adjustedClose = ohlc.adjustedClose.toDouble(),
                let close = ohlc.close.toDouble()
        else { return nil }
        
        return open * adjustedClose / close
    }
}

struct Meta: Decodable {
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
        case symbol = "2. Symbol"
    }
}

struct OpenHighLowClose: Decodable {
    let open: String
    let close: String
    let adjustedClose: String
    
    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case close = "4. close"
        case adjustedClose = "5. adjusted close"
    }
}
