//
//  OTPKit+Extensions.swift
//  
//
//  Created by Sergei Belous on 6.03.21.
//

import Foundation
import OTPKit

public extension OTPProvidable {
    var currentOTP: String {
        getOTP(for: Date())
    }
}

extension HMACAlgorithm: Codable {}

extension MovingFactor: Codable {

    private enum CodingKeys: String, CodingKey {
        case timer
    }

    enum MovingFactorCodingError: Error {
        case decoding(String)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(TimeInterval.self, forKey: .timer) {
            self = .timer(period: value)
            return
        }
        throw MovingFactorCodingError.decoding("Whoops! \(dump(values))")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .timer(let period):
            try container.encode(period, forKey: .timer)
        }
    }
}
