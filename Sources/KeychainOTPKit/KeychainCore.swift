//
//  KeychainCore.swift
//  AnotherFactor
//
//  Created by Sergey Belous on 25.12.19.
//  Copyright © 2019 Sergey Belous. All rights reserved.
//

import Foundation

public typealias KeychainService = String
private typealias QueryDictionary = [String: Any]

public final class KeychainCore: Storable {

    private let keychainService: KeychainService

    public init(keychainService: KeychainService) {
        self.keychainService = keychainService
    }

    public func save(userData: UserData, uuid: UUID, secretData: SecretData) -> Result<Void, StorableError> {
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
            return .success(())
        default:
            return .failure(StorableError.genericError)
        }
    }

    public func retriveRawData() -> Result<[StorableData], StorableError> {
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
            guard let data = ref as? [StorableRawData] else {
                return .failure(StorableError.noData)
            }
            do {
                let result: [StorableData] = try data.map(extractAccount).map { item in
                    switch item {
                    case .success(let account):
                        return account
                    case .failure(let error):
                        throw error
                    }
                }
                return .success(result)
            } catch {
                return .failure(StorableError.readingError)
            }
        case errSecItemNotFound:
            return .failure(StorableError.notFound(name: keychainService))
        default:
            return .failure(StorableError.genericError)
        }
    }

    public func extractAccount(from rawData: StorableRawData) -> Result<StorableData, StorableError> {
        if let userData = rawData[kSecAttrGeneric as String] as? UserData,
           let secretData = rawData[kSecValueData as String] as? SecretData,
           let persistentRef = rawData[kSecValuePersistentRef as String] as? PersistentRef {
            return .success(StorableData(userData: userData, secretData: secretData, persistentRef: persistentRef))
        } else {
            return .failure(StorableError.readingError)
        }
    }

    public func retriveSecret(at persistentRef: PersistentRef) -> Result<SecretData, StorableError> {
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
            guard let existingItem = item as? StorableRawData,
                let secretData = existingItem[kSecValueData as String] as? SecretData else {
                    return .failure(StorableError.noData)
            }
            return .success(secretData)
        default:
            return .failure(StorableError.genericError)
        }
    }

    public func remove(at persistentRef: PersistentRef) -> Result<Void, StorableError> {
        let query: QueryDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecValuePersistentRef as String: persistentRef
        ]

        switch SecItemDelete(query as CFDictionary) {
        case errSecSuccess, errSecItemNotFound:
            return .success(())
        default:
            return .failure(StorableError.genericError)
        }
    }
}
