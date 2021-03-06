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
