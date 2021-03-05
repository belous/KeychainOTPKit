//
//  Account.swift
//  AnotherFactor
//
//  Created by Sergei Belous on 12.02.21.
//

import Foundation

public struct Account: Hashable, Codable {
    public let issuer: String
    public let label: String
    public let secret: Secret
    public let id: UUID
    public let persistentRef: PersistentRef

    public init(issuer: String, label: String, secret: Secret, id: UUID, persistentRef: PersistentRef) {
        self.issuer = issuer
        self.label = label
        self.secret = secret
        self.id = id
        self.persistentRef = persistentRef
    }
}
