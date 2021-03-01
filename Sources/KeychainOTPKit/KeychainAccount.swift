//
//  KeychainAccount.swift
//  AnotherFactor
//
//  Created by Sergei Belous on 17.02.21.
//

import Foundation

struct KeychainAccount: Hashable, Codable {
    let issuer: String
    let label: String
    let id: UUID
}

extension KeychainAccount {
    init(from account: Account) {
        self.init(issuer: account.issuer, label: account.label, id: account.id)
    }
}
