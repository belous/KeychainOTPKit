//
//  KeychainCore.swift
//  AnotherFactor
//
//  Created by Sergey Belous on 25.12.19.
//  Copyright © 2019 Sergey Belous. All rights reserved.
//

import Foundation

public typealias UserData = Data
public typealias SecretData = Data
public typealias PersistentRef = Data
public typealias KeychainService = String
public typealias KeychainRawData = [String: Any]

private typealias QueryDictionary = [String: Any]

enum KeychainCoreError: Error {
    case error
    case noData
    case notFound(name: String)
}

public final class KeychainCore {
    private let keychainService: KeychainService

    public init(keychainService: KeychainService) {
        self.keychainService = keychainService
    }

    public func save(userData: UserData, uuid: UUID, secretData: SecretData) -> Result<CFTypeRef?, Error> {
        let query: QueryDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: uuid.uuidString,
            kSecAttrService as String: keychainService,
            kSecAttrGeneric as String: userData,
            kSecValueData as String: secretData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecReturnPersistentRef as String: true
        ]

        var ref: CFTypeRef?
        switch SecItemAdd(query as CFDictionary, &ref) {
        case errSecSuccess:
            return .success(ref)
        default:
            return .failure(KeychainCoreError.error)
        }
    }

    public func retriveRawData() -> Result<[KeychainRawData], Error> {
        let query: QueryDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecAttrService as String: keychainService,
            kSecReturnData as String: true,
            kSecReturnAttributes as String: true,
            kSecReturnPersistentRef as String: true
        ]

        var ref: CFTypeRef?

        switch SecItemCopyMatching(query as CFDictionary, &ref) {
        case errSecSuccess:
            guard let data = ref as? [KeychainRawData] else {
                return .failure(KeychainCoreError.noData)
            }
            return .success(data)
        case errSecItemNotFound:
            return .failure(KeychainCoreError.notFound(name: keychainService))
        default:
            return .failure(KeychainCoreError.error)
        }
    }

    public func retriveSecret(at persistentRef: PersistentRef) -> Result<SecretData, Error> {
        let query: QueryDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
            kSecValuePersistentRef as String: persistentRef
        ]

        var item: CFTypeRef?

        switch SecItemCopyMatching(query as CFDictionary, &item) {
        case errSecSuccess:
            guard let existingItem = item as? KeychainRawData,
                let secretData = existingItem[kSecValueData as String] as? SecretData else {
                    return .failure(KeychainCoreError.noData)
            }
            return .success(secretData)
        default:
            return .failure(KeychainCoreError.error)
        }
    }

    public func remove(at persistentRef: PersistentRef) -> Result<Void, Error> {
        let query: QueryDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecValuePersistentRef as String: persistentRef
        ]

        switch SecItemDelete(query as CFDictionary) {
        case errSecSuccess, errSecItemNotFound:
            return .success(())
        default:
            return .failure(KeychainCoreError.error)
        }
    }
}
