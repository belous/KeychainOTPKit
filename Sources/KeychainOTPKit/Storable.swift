//
//  File.swift
//  
//
//  Created by Sergei Belous on 5.03.21.
//

import Foundation

public typealias UserData = Data
public typealias SecretData = Data
public typealias PersistentRef = Data
public typealias StorableRawData = [String: Any]
public typealias KeychainRawData = [String: Any]

public enum StorableError: Error {
    case noData
    case notFound(name: String)
    case genericError
}

public protocol Storable {
    func save(userData: UserData, uuid: UUID, secretData: SecretData) -> Result<Void, StorableError>
    func remove(at persistentRef: PersistentRef) -> Result<Void, StorableError>
    func retriveRawData() -> Result<[StorableRawData], StorableError>
    func retriveSecret(at persistentRef: PersistentRef) -> Result<SecretData, StorableError>
}
