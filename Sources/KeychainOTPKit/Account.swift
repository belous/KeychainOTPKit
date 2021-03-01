//
//  Account.swift
//  AnotherFactor
//
//  Created by Sergei Belous on 12.02.21.
//

import Foundation

enum AccountError: Error {
    case decodingError
}

private let decoder = JSONDecoder()

public struct Account: Hashable, Codable {
    let issuer: String
    let label: String
    let secret: Secret
    let id: UUID
    let persistentRef: PersistentRef

    public init(issuer: String, label: String, secret: Secret, id: UUID, persistentRef: PersistentRef) {
        self.issuer = issuer
        self.label = label
        self.secret = secret
        self.id = id
        self.persistentRef = persistentRef
    }
}

extension Account {
    init?(userData: UserData, secretData: SecretData, persistentRef: PersistentRef) {
        let userDataDecoded = decoder.decode(userData, KeychainAccount.self)
        let secretDataDecoded = decoder.decode(secretData, Secret.self)

        switch (userDataDecoded, secretDataDecoded) {
        case (.success(let keychainAccount), .success(let secret)):
            self.init(from: keychainAccount, secret: secret, persistentRef: persistentRef)
        case (_, _):
            return nil
        }
    }

    init(from keychainAccount: KeychainAccount, secret: Secret, persistentRef: PersistentRef) {
        self.init(issuer: keychainAccount.issuer, label: keychainAccount.label, secret: secret, id: keychainAccount.id, persistentRef: persistentRef)
    }
}

fileprivate extension JSONDecoder {
    func decode<T>(_ data: Data, _ type: T.Type) -> Result<T, Error> where T: Decodable {
        do {
            let result = try self.decode(type.self, from: data)
            return .success(result)
        } catch let error {
            print("Decode failed: `\(error)`")
            return .failure(AccountError.decodingError)
        }
    }
}
