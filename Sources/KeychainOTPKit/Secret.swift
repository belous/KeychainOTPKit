//
//  Secret.swift
//  OTP
//
//  Created by Sergey Belous on 22.9.2019.
//  Copyright © 2019 Sergey Belous. All rights reserved.
//

import Foundation
import OTPKit

public struct Secret: Codable, Equatable, Hashable {
    public let secret: String
    public let digits: Int
    public let movingFactor: MovingFactor
    public let hmacAlgorithm: HMACAlgorithm
    public var uuid = UUID()

    public init(secret: String,
                digits: Int = 6,
                movingFactor: MovingFactor = .timer(period: 30),
                hmacAlgorithm: HMACAlgorithm = .sha1) {
        self.secret = secret
        self.digits = digits
        self.movingFactor = movingFactor
        self.hmacAlgorithm = hmacAlgorithm
    }
}

extension Secret: OTPProvidable {}

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
